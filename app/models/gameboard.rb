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

    gameboard = Gameboard.find(gameboard.id)

    Centercard.create(gameboard_id: gameboard.id)

    gameboard.players.each do |player|
      # ##only for debug
      # TODO: remove later
      Inventory.create(player: player) unless player.inventory

      pp player.inventory.cards

      Handcard.create(player: player) unless player.handcard

      pp player.handcard.cards

      Monsterone.create(player: player) unless player.monsterone

      pp player.monsterone.cards

      Monstertwo.create(player: player) unless player.monstertwo

      pp player.monstertwo.cards
      Monsterthree.create(player: player) unless player.monsterthree

      pp player.monsterthree.cards

      Playercurse.create(player: player) unless player.playercurse

      pp player.playercurse.cards
      pp "player ud"
      pp player.id

      players_array.push({ name: player.name, player_id: player.id, inventory: player.inventory.cards, handcard: player.handcard.cards.count, monsterone: player.monsterone.cards, monstertwo: player.monstertwo.cards,
                          monsterthree: player.monsterthree.cards })
    end

    pp     output = { # add center
      # graveyard: gameboard.graveyard,
      players: players_array,
      # needs more info
      gameboard: gameboard
    }

    output = { # add center
      # graveyard: gameboard.graveyard,
      players: players_array,
      # needs more info
      gameboard: gameboard
    }
  end
end
