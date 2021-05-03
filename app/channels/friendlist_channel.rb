# frozen_string_literal: true

class FriendlistChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user

    current_user.update(online: true)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    current_user.update(online: false)
  end

  def send_friend_request(data)
    future_friend = User.find_by('id=?', data['friend'])

    Friendship.add_friend(current_user, future_friend)

    broadcast_to(current_user, { type: 'FRIEND_LOG', params: { message: "You sent a friendrequest to #{future_friend.name}" } })
    broadcast_to(future_friend, { type: 'FRIEND_LOG', params: { message: "#{current_user.name} sent you a friendrequest" } })
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
end
