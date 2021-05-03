# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  validates_presence_of :email
  validates_uniqueness_of :email
  validates_presence_of :name
  validates_uniqueness_of :name

  # inventory
  has_and_belongs_to_many :cards

  has_one :player
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships, class_name: 'User'

  def self.add_friend(user1, user2)
    user2.friends << user1
    user1.friends << user2
  end

  def self.remove_friend(user1, user2)
    friendship1 = Friendship.where(['user_id = ? and friend_id = ?', user1.id, user2.id]).first
    friendship2 = Friendship.where(['user_id = ? and friend_id = ?', user2.id, user1.id]).first

    Friendship.destroy(friendship1.id)
    Friendship.destroy(friendship2.id)
  end
end
