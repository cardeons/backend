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

  def init_player(params = {})
    handcard ||= Handcard.create(player_id: id)

    Inventory.create!(player: self) unless inventory
    Monsterone.create!(player: self) unless monsterone
    Monstertwo.create!(player: self) unless monstertwo
    Monsterthree.create!(player: self) unless monsterthree
    Handcard.create!(player: self) unless handcard
    Playercurse.create!(player: self) unless playercurse

    # add the monsters from the player to his handcards
    # TODO: Check if player actually posesses these cards
    Ingamedeck.create(card_id: params[:monsterone], gameboard: gameboard, cardable: handcard) if params[:monsterone]
    Ingamedeck.create(card_id: params[:monstertwo], gameboard: gameboard, cardable: handcard) if params[:monstertwo]
    Ingamedeck.create(card_id: params[:monsterthree], gameboard: gameboard, cardable: handcard) if params[:monsterthree]
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

  def render_player(player)
    # Inventory.find_or_create_by!(player: self) # unless player.inventory

    # Handcard.find_or_create_by!(player: self) # unless player.handcard

    # Monsterone.find_or_create_by!(player: self) # unless player.monsterone

    # Monstertwo.find_or_create_by!(player: self) # unless player.monstertwo

    # Monsterthree.find_or_create_by!(player: self) # unless player.monsterthree

    # Playercurse.find_or_create_by!(player: self) # unless player.playercurse

    monsters = []

    if monsterone.ingamedecks&.first
      monsters.push(
        Gameboard.render_user_monsters(player, 'Monsterone')
      )
    end
    if monstertwo.ingamedecks&.first
      monsters.push(
        Gameboard.render_user_monsters(player, 'Monstertwo')
      )
    end
    if monsterthree.ingamedecks&.first
      monsters.push(
        Gameboard.render_user_monsters(player, 'Monsterthree')
      )
    end
    { name: name, player_id: id, inventory: Gameboard.render_cards_array(inventory.ingamedecks), level: level, attack: attack,
      handcard: handcard.cards.count, monsters: monsters, playercurse: Gameboard.render_cards_array(playercurse.ingamedecks), user_id: user.id }
  end
end
