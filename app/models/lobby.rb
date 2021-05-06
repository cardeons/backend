# frozen_string_literal: true

class Lobby < ApplicationRecord
  has_many :users
end
