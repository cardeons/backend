# frozen_string_literal: true
require "pp"

class Monstercard < Card
  validates :title, :description, :image, :action, :draw_chance, :level, :element, :bad_things, :rewards_treasure, :atk_points, :level_amount, :type, presence: true

  def self.equip_monster(params)
    
    #TODO frontend schickt player und unique card_id und monsterslot
    player = Player.find_by("id=?", params["player_id"])
    gameboard = Gameboard.find_by("id=?", params["gameboard_id"])
    # monster = Monstercard.find_by("id=?", params["monster_id"])
    # monstertype = monster.type
    deck_card = Ingamedeck.find_by("id=?", params["item_id"])
    # deck_card = Ingamedeck.find_by("id=?", card_id)


    pp player
    pp gameboard
    # pp monster
    # pp monstertype
    pp deck_card

    # pp player.monstertwo.cards

    #define which monster
    case params["slot"]
    when "Monsterone"
      monster_to_equip = player.monsterone
    when "Monstertwo"
      monster_to_equip = player.monstertwo
    else
      monster_to_equip = player.monsterthree
    end

pp monster_to_equip
#   type = "ERROR" 

#     #find "original" card, only advance if found
    unless deck_card.nil?
      card = Card.find_by("id=?", deck_card.card_id)
      #TODO validieren
      cardtype = card.type

      pp card
#       # there already are 5 items, you can't put any mor (6 because the monster itself is in this table)
      if monster_to_equip.cards.count == 6
          type = "ERROR"
          message = "You can't put any more items on this monster."
          # GameChannel.broadcast_to(gameboard, {type: 'ERROR', params: { message: "You can't put any more items on this monster." } })

      # category already on monster
      elsif monster_to_equip.cards.where("item_category=?", card.item_category).count > 0
          type = "ERROR"
          message = "You already have this type of item on your monster! (#{card.item_category})"
          # GameChannel.broadcast_to(gameboard, {type: 'ERROR', params: { message: "You already have this type of item on your monster! (#{card.item_category})" } })

      # not an item
      elsif cardtype != "Itemcard"
          type = "ERROR"
          message = "Sorry, you can't put anything on your monster that is not an item!"
          # GameChannel.broadcast_to(gameboard, {type: 'ERROR', params: { message: "Sorry, you can't put anything on your monster that is not an item!"} })

      # yay
      else
          type = "GAMEBOARD_UPDATE"
          deck_card.update_attribute(:cardable_type, params["slot"])
          player_atk = monster_to_equip.cards.sum(:atk_points)
          player.update_attribute(:attack, player_atk)
          message = "Successfully equipped."
          # GameChannel.broadcast_to(gameboard, {type: 'GAMEBOARD_UPDATE', params: Gameboard.broadcast_game_board(gameboard) })
      end
    end

    if deck_card == nil
      type = "ERROR"
      message = "Card not found. Something went wrong."
      # GameChannel.broadcast_to(gameboard, {type: 'ERROR', params: { message: "Card not found"} })
    end
# type = "equip"
    {type: type, message: message}
  end
end
