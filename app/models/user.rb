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

end
