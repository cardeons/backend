# frozen_string_literal: true
require "pp"

class Monstercard < Card
  validates :title, :description, :image, :action, :draw_chance, :level, :element, :bad_things, :rewards_treasure, :atk_points, :level_amount, :type, presence: true


  def self.equip_monster(monster, player_id, gameboard_id, card_id, monsterslot)
    
    #TODO frontend schickt player und unique card_id und monsterslot
    player = Player.find(player_id)
    gameboard = Gameboard.find_by(gameboard_id)
    # pp player
    # pp player.monsterone

    #define which monster
    case monsterslot
    when "Monsterone"
      monster_to_equip = player.monsterone
    when "Monstertwo"
      monster_to_equip = player.monstertwo
    else
      monster_to_equip = player.monsterthree
    end


    #find ingamedeck card
    deck_card = Ingamedeck.find_by("id=?", card_id)

    # pp deck_card

  #find "original" card, only advance if found
    unless deck_card.nil?
      card = Card.find_by("id=?", deck_card.card_id)
      #TODO validieren
      cardtype = card.type

      # there already are 5 items, you can't put any mor (6 because the monster itself is in this table)
      if monster_to_equip.cards.count == 6
          puts "**************"
          error_message = "sorry you can't put any more items on this monster"
          GameChannel.broadcast_to(gameboard, {type: 'MONSTER_EQUIP_FAIL', params: { message: "You can't put any more items on this monster." } })
      # category already on monster
      elsif monster_to_equip.cards.where("item_category=?", card.item_category).count > 0
          puts "**************"
          error_message = "nono not allowed, you already have " + card.item_category
          GameChannel.broadcast_to(gameboard, {type: 'MONSTER_EQUIP_FAIL', params: { message: "You already have this type of item on your monster! (#{card.item_category})" } })
      # not an item
      elsif cardtype != "Itemcard"
          puts "**************"
          error_message = "sorry you can't put anything on your monster that's not an item"
          GameChannel.broadcast_to(gameboard, {type: 'MONSTER_EQUIP_FAIL', params: { message: "Sorry, you can't put anything on your monster that is not an item!"} })
      # yay
      else
          puts "************** created Card *************"
          deck_card.update_attribute(:cardable_type, monsterslot)
          player_atk = monster_to_equip.cards.sum(:atk_points)
          player.update_attribute(:attack, player_atk)
          puts "************** created Card *************"
          error_message = "no problem"

          GameChannel.broadcast_to(gameboard, {type: 'MONSTER_EQUIP_SUCCESS', params: Gameboard.broadcast_game_board(gameboard) })
      end
    end

    if error_message.nil?
      error_message = "Something went wrong with finding the card"
    end
  end
end
