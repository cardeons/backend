# frozen_string_literal: true

class Gameboard < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :ingamedeck, dependent: :destroy
  has_one :player, foreign_key: 'current_player'
  # has_many :cards, through: :ingame_cards

  def self.initialize_gameBoard(gameboard)
    gameboard.current_player = gameboard.players.first
    gameboard.current_state = 'playing'
    # TODO: add first monster?

    gameboard.player.each do |player|
      Player.draw_five_cards(player)
    end

    gameboard.save!
  end
end
