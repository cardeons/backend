# frozen_string_literal: true

class Friend < ApplicationRecord
  has_many :friendships
  has_many :users, through: :friendships
end
