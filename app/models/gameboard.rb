# frozen_string_literal: true

class Gameboard < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :ingamedeck, dependent: :destroy
  has_one :player, :foreign_key => "current_player"
  # has_many :cards, through: :ingame_cards
end
