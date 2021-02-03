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

    gameboard.players.each do |player|
      Player.draw_five_cards(player)
    end

    gameboard.save!
  end

  def self.broadcast_gameBoard(gameboard)
    playersArray = []

    gameboard.players.each do |player|
      puts player
      puts player.inventory

      # ##only for debug
      # TODO: remove later
      Inventory.create(player_id: player.id) unless player.inventory

      Handcard.create(player_id: player.id) unless player.handcard

      Monsterone.create(player_id: player.id) unless player.monsterone

      Monstertwo.create(player_id: player.id) unless player.monstertwo

      Monsterthree.create(player_id: player.id) unless player.monsterthree

      playersArray.push({ name: player.name, player_id: player.id ,inventory: player.inventory.cards, handcard: player.handcard.cards.count, monsterthree: player.monsterone.cards, monstertwo: player.monstertwo.cards,
                          monsterthree: player.monsterthree.cards })
    end

    output = { # add center
      # graveyard: gameboard.graveyard,
      players: playersArray,
      # needs more info
      gameboard: gameboard
    }

  end
end
