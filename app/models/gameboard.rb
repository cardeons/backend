# frozen_string_literal: true
require 'pp'

class Gameboard < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :ingamedeck, dependent: :destroy
  has_one :player, foreign_key: 'current_player'
  has_one :centercard

  # has_many :cards, through: :ingame_cards

  def self.initialize_game_board(gameboard)
    gameboard.update(current_player: gameboard.players.last.id, current_state: 'started')
    # Gameboard.find(gameboard.id).save

    gameboard.players.each do |player|
      # Player.draw_five_cards(player)

      unless player.handcard
        Handcard.create(player_id: player.id)
      end

      Handcard.draw_handcards(player.id, gameboard)

    end

  end

  def self.broadcast_game_board(gameboard)
    players_array = []

    gameboard.players.each do |player|
      # ##only for debug
      # TODO: remove later
      Inventory.create(player_id: player.id) unless player.inventory

      Handcard.create(player_id: player.id) unless player.handcard

      Monsterone.create(player_id: player.id) unless player.monsterone

      Monstertwo.create(player_id: player.id) unless player.monstertwo

      Monsterthree.create(player_id: player.id) unless player.monsterthree

      players_array.push({ name: player.name, player_id: player.id, inventory: player.inventory.cards, handcard: player.handcard.cards.count, monsterone: player.monsterone.cards, monstertwo: player.monstertwo.cards,
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
