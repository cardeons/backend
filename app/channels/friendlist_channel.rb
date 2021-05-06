# frozen_string_literal: true

class FriendlistChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user

    current_user.update(status: :online)

    Friendship.broadcast_friends(current_user)
    Friendship.broadcast_pending_requests(current_user)
    broadcast_status_to_friends
  end

  def unsubscribed
    current_user.update(status: :offline)
    broadcast_status_to_friends
  end

  def load_friends
    Friendship.broadcast_friends(current_user)
    Friendship.broadcast_pending_requests(current_user)
  end

  def send_friend_request(data)
    future_friend = User.find_by('id=?', data['friend'])

    Friendship.add_friend(current_user, future_friend)

    broadcast_to(current_user, { type: 'FRIEND_LOG', params: { message: "You sent a friendrequest to #{future_friend.name}" } })
    broadcast_to(future_friend, { type: 'FRIEND_LOG', params: { message: "#{current_user.name} sent you a friendrequest" } })
    broadcast_to(future_friend, { type: 'FRIEND_REQUEST', params: { inquirer: current_user.id, inquirer_name: current_user.name } })
  end

  def accept_friend_request(data)
    inquirer = User.find_by('id=?', data['inquirer'])

    Friendship.accept(current_user, inquirer)
    Friendship.broadcast_friends(current_user)
    Friendship.broadcast_friends(inquirer)

    broadcast_to(current_user, { type: 'FRIEND_LOG', params: { message: "You accepted a friendrequest from #{inquirer.name}" } })
    broadcast_to(inquirer, { type: 'FRIEND_LOG', params: { message: "#{current_user.name} accepted your friendrequest" } })
  end

  def decline_friend_request(data)
    inquirer = User.find_by('id=?', data['inquirer'])

    Friendship.remove_friend(current_user, inquirer)
    broadcast_to(current_user, { type: 'FRIEND_LOG', params: { message: "You declined a friendrequest from #{inquirer.name}" } })
  end

  # def initiate_lobby
  #   lobby = Lobby.create!

  #   current_user.update!(lobby: lobby)
  # end

  # def lobby_invite(data)
  #   friend = User.find_by('id=?', data['friend'])

  #   broadcast_to(friend, { type: 'GAME_INVITE', params: { inviter: current_user.id, inviter_name: current_user.name } })
  # end

  # def accept_lobby_invite(data)
  #   inquirer = User.find_by('id=?', data['inquirer'])

  #   broadcast_to(current_user, { type: 'LOBBY_ERROR', params: { message: 'Lobby is full...' } }) if inquirer.lobby.users.count == 4
  #   current_user.update!(lobby: inquirer.lobby) if inquirer.lobby.users.count < 4
  # end

  # def start_lobby_queue
  #   lobby = current_user.lobby

  #   delete_old_players

  #   gameboard = Gameboard.find_or_create_by!(current_state: :lobby)

  #   gameboard = Gameboard.create!(current_state: :lobby) if lobby.users.reload.count > (4 - gameboard.players.reload.count)

  #   lobby.users.each do |user|
  #     Player.create!(name: user.name, gameboard_id: gameboard.id, user: user)

  #     broadcast_to(user, { type: 'SUBSCRIBE_LOBBY', params: { game_id: gameboard.id } })
  #   end
  # end

  def broadcast_status_to_friends
    current_user.friends.each do |friend|
      Friendship.broadcast_friends(friend)
    end
  end
end
