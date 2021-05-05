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

  def broadcast_status_to_friends
    current_user.friends.each do |friend|
      Friendship.broadcast_friends(friend)
    end
  end
end
