# frozen_string_literal: true

class FriendlistChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user

    current_user.update(status: :online)

    Friendship.broadcast_friends(current_user)
    Friendship.broadcast_pending_requests(current_user)
  end

  def unsubscribed
    current_user.update(status: :offline)
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

    broadcast_to(current_user, { type: 'FRIEND_LOG', params: { message: "You accepted a friendrequest from #{inquirer.name}" } })
    broadcast_to(inquirer, { type: 'FRIEND_LOG', params: { message: "#{current_user.name} accepted your friendrequest" } })
  end

  def decline_friend_request(data)
    inquirer = User.find_by('id=?', data['inquirer'])

    Friendship.remove_friend(current_user, inquirer)
    broadcast_to(current_user, { type: 'FRIEND_LOG', params: { message: "You declined a friendrequest from #{inquirer.name}" } })
  end

  def initiate_lobby
    lobby = Lobby.create!

    current_user.update!(lobby: lobby)
  end

  def lobby_invite(data)
    friend = User.find_by('id=?', data['friend'])

    broadcast_to(friend, { type: 'GAME_INVITE', params: { inviter: current_user.id, inviter_name: current_user.name } })
  end

  def accept_lobby_invite(data)
    inquirer = User.find_by('id=?', data['inquirer'])

    broadcast_to(current_user, { type: 'LOBBY_ERROR', params: { message: 'Lobby is full...' } }) if inquirer.lobby.users.count == 4
    current_user.update!(lobby: inquirer.lobby) if inquirer.lobby.users.count < 4
  end

  def start_lobby_queue
    lobby = current_user.lobby

    delete_old_players

    gameboard = Gameboard.find_or_create_by!(current_state: :lobby)

    gameboard = Gameboard.create!(current_state: :lobby) if lobby.users.reload.count > (4 - gameboard.players.reload.count)

    lobby.users.each do |user|
      Player.create!(name: user.name, gameboard_id: gameboard.id, user: user)

      broadcast_to(user, { type: 'SUBSCRIBE_LOBBY', params: { game_id: gameboard.id } })
    end
  end

  private

  def delete_old_players
    # search if user is already in a game
    old_players = Player.where('user_id=?', current_user.id)
    old_players.each do |player|
      # if its the current players turn get the next one in line
      old_gameboard = player.gameboard
      if old_gameboard.current_player == player
        Gameboard.get_next_player(old_gameboard) if old_gameboard.current_player == player
        old_gameboard.reload
        if old_gameboard.current_player == player || old_gameboard.players.count < 3
          old_gameboard.current_player = nil
          old_gameboard.save!
          old_gameboard.destroy!
          next
        end
        # just set current_player to il for now
        # old_gameboard.current_player = nil
      end
      player.destroy!
    end
  end
end
