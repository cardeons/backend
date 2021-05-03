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
end
