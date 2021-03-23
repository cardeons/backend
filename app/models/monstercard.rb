# frozen_string_literal: true

class Monstercard < Card
  validates :title, :description, :image, :action, :draw_chance, :level, :element, :bad_things, :rewards_treasure, :atk_points, :level_amount, :type, presence: true

  def self.equip_monster(params, player)

    deck_card = Ingamedeck.find_by('id=?', params['unique_equip_id'])
    monsterslot = Ingamedeck.find_by('id=?', params['unique_monster_id'])

    # define which monster
    monster_to_equip = case monsterslot.cardable_type
                       when 'Monsterone'
                         player.monsterone
                       when 'Monstertwo'
                         player.monstertwo
                       else
                         player.monsterthree
                       end

    #     #find "original" card, only advance if found
    unless deck_card.nil?
      card = Card.find_by('id=?', deck_card.card_id)

      pp "---------------"
      pp card
      pp "---------------"
      # TODO: validieren
      cardtype = card.type
      #       # there already are 5 items, you can't put any more (6 because the monster itself is in this table)
      if monster_to_equip.cards.count == 6
        type = 'ERROR'
        message = "You can't put any more items on this monster."
      # GameChannel.broadcast_to(gameboard, {type: 'ERROR', params: { message: "You can't put any more items on this monster." } })

      # category already on monster
      elsif monster_to_equip.cards.where('item_category=?', card.item_category).count.positive?

        pp "in here"
        pp card.item_category
        pp monster_to_equip.cards.where('item_category=?', card.item_category).count

        if card.item_category == "hand" && monster_to_equip.cards.where('item_category=?', card.item_category).count == 1
          pp "erlaubt"
          type = 'GAMEBOARD_UPDATE'
          message = 'Successfully equipped.'
          deck_card.update_attribute(:cardable, monster_to_equip)
        else
          pp "nicht erlaubt"
        type = 'ERROR'
        message = "You already have this type of item on your monster! (#{card.item_category})"
        end
      # GameChannel.broadcast_to(gameboard, {type: 'ERROR', params: { message: "You already have this type of item on your monster! (#{card.item_category})" } })

      # not an item
      elsif cardtype != 'Itemcard'
        type = 'ERROR'
        message = "Sorry, you can't put anything on your monster that is not an item!"
      # GameChannel.broadcast_to(gameboard, {type: 'ERROR', params: { message: "Sorry, you can't put anything on your monster that is not an item!"} })

      # yay
      else

        pp "all good"
        type = 'GAMEBOARD_UPDATE'
        deck_card.update_attribute(:cardable, monster_to_equip)

        # player_atk = monster_to_equip.cards.sum(:atk_points)

        # result = player.gameboard.monster_atk < player_atk
        # player.gameboard.update_attribute(:success, result)
        # GameChannel.broadcast_to(gameboard, {type: 'GAMEBOARD_UPDATE', params: Gameboard.broadcast_game_board(gameboard) })

        # get updatet result of attack
        attack_obj = Gameboard.attack(player.gameboard)

        monstercards1 = player.monsterone ? player.monsterone.cards.sum(:atk_points) : 0

        monstercards2 = player.monstertwo ? player.monstertwo.cards.sum(:atk_points) : 0

        monstercards3 = player.monsterthree ? player.monsterthree.cards.sum(:atk_points) : 0

        playeratkpoints = monstercards1 + monstercards2 + monstercards3 + player.level

        player.update_attribute(:attack, playeratkpoints)
        player.gameboard.update(success: attack_obj[:result], player_atk: attack_obj[:playeratk], monster_atk: attack_obj[:monsteratk])
        message = 'Successfully equipped.'
      end
    end

    if deck_card.nil?
      type = 'ERROR'
      message = 'Card not found. Something went wrong.'
      # GameChannel.broadcast_to(gameboard, {type: 'ERROR', params: { message: "Card not found"} })
    end
    # type = "equip"
    { type: type, message: message }
  end
end
