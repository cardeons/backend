# frozen_string_literal: true

class Player < ApplicationRecord
  belongs_to :gameboard
  has_one :inventory, dependent: :destroy
  has_one :handcard, dependent: :destroy
  has_one :monsterone, dependent: :destroy
  has_one :monstertwo, dependent: :destroy
  has_one :monsterthree, dependent: :destroy
  has_one :playercurse, dependent: :destroy
  belongs_to :user


  def init_player(params)

  end

  def self.draw_five_cards(player)
    # handcard = Handcard.create(player_id: player.id)
    # TODO: make it random
    # Ingamedeck.new(gameboard_id: player.gameboard_id, card_id: 1, cardable_id: 1, cardable_type: 'Handcard').save!
    # Ingamedeck.new(gameboard_id: player.gameboard_id, card_id: 2, cardable_id: 1, cardable_type: 'Handcard').save!
    # Ingamedeck.new(gameboard_id: player.gameboard_id, card_id: 1, cardable_id: 1, cardable_type: 'Handcard').save!
    # Ingamedeck.new(gameboard_id: player.gameboard_id, card_id: 2, cardable_id: 1, cardable_type: 'Handcard').save!
    # Ingamedeck.new(gameboard_id: player.gameboard_id, card_id: 1, cardable_id: 1, cardable_type: 'Handcard').save!
    # Ingamedeck.new(gameboard_id: player.gameboard_id, card_id: 2, cardable_id: 1, cardable_type: 'Handcard').save!
  end
end
