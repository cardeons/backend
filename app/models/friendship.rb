class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  def self.add_friend(user1, user2)
    user2.friends << user1
    user1.friends << user2
  end

  def self.remove_friend(user1, user2)
    friendship1 = Friendship.where(['user_id = ? and friend_id = ?', user1.id, user2.id]).first
    friendship2 = Friendship.where(['user_id = ? and friend_id = ?', user2.id, user1.id]).first

    friendship1 ? Friendship.destroy(friendship1.id) : nil
    friendship2 ? Friendship.destroy(friendship2.id) : nil
  end

  def self.accept(user1, user2)
    friendship1 = Friendship.where(['user_id = ? and friend_id = ?', user1.id, user2.id]).first
    friendship2 = Friendship.where(['user_id = ? and friend_id = ?', user2.id, user1.id]).first

    friendship1.update!(pending: false)
    friendship2.update!(pending: false)
  end

  def self.broadcast_pending_requests(current_user)
    pending_requests = Friendship.where(['user_id = ? and pending = ?', current_user.id, true])

    pending_requests.each do |request|
      FriendlistChannel.broadcast_to(current_user, { type: 'FRIEND_REQUEST', params: { inquirer: request.friend.id, inquirer_name: request.friend.name } })
    end
  end
end
