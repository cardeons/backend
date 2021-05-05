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

      cardtype = card.type
      # there already are 5 items, you can't put any more (6 because the monster itself is in this table)
      if monster_to_equip.cards.count == 6
        type = 'ERROR'
        message = "You can't put any more items on this monster."
      # GameChannel.broadcast_to(gameboard, {type: 'ERROR', params: { message: "You can't put any more items on this monster." } })

      # category already on monster
      elsif monster_to_equip.cards.where('item_category=?', card.item_category).count.positive?

        if card.item_category == 'hand' && monster_to_equip.cards.where('item_category=?', card.item_category).count == 1
          type = 'GAMEBOARD_UPDATE'
          message = 'Successfully equipped.'
          deck_card.update(cardable: monster_to_equip)

          attack_obj = Gameboard.attack(player.gameboard)

          monstercards1 = Monstercard.calculate_monsterslot_atk(player.monsterone)
          monstercards2 = Monstercard.calculate_monsterslot_atk(player.monstertwo)
          monstercards3 = Monstercard.calculate_monsterslot_atk(player.monsterthree)

          playeratkpoints = monstercards1 + monstercards2 + monstercards3 + player.level

          player.update!(attack: playeratkpoints)
          player.gameboard.update(success: attack_obj[:result], player_atk: attack_obj[:playeratk], monster_atk: attack_obj[:monsteratk])

        else
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
        type = 'GAMEBOARD_UPDATE'
        deck_card.update(cardable: monster_to_equip)

        # player_atk = monster_to_equip.cards.sum(:atk_points)

        # result = player.gameboard.monster_atk < player_atk
        # player.gameboard.update_attribute(:success, result)
        # GameChannel.broadcast_to(gameboard, {type: 'GAMEBOARD_UPDATE', params: Gameboard.broadcast_game_board(gameboard) })

        # get updatet result of attack
        attack_obj = Gameboard.attack(player.gameboard)

        monstercards1 = Monstercard.calculate_monsterslot_atk(player.monsterone)
        monstercards2 = Monstercard.calculate_monsterslot_atk(player.monstertwo)
        monstercards3 = Monstercard.calculate_monsterslot_atk(player.monsterthree)

        playeratkpoints = monstercards1 + monstercards2 + monstercards3 + player.level

        player.update(attack: playeratkpoints)
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

  def self.calculate_monsterslot_atk(monsterslot)
    monstercards = 0
    if monsterslot
      monstercards = 1 if monsterslot.cards.where(type: 'Monstercard').any?
      monstercards += monsterslot.cards.where(type: 'Itemcard').sum(:atk_points)
    end

    monstercards
  end

  def self.lose_item_by_category(player, gameboard, category)
    monster_arr = []
    monster_slot = []
    if player.monsterone.cards.where(item_category: category).any?
      monster_arr.push(player.monsterone.cards.where(item_category: category))
      monster_slot.push(player.monsterone)
    end
    if player.monstertwo.cards.where(item_category: category).any?
      monster_arr.push(player.monstertwo.cards.where(item_category: category))
      monster_slot.push(player.monstertwo)
    end
    if player.monsterthree.cards.where(item_category: category).any?
      monster_arr.push(player.monsterthree.cards.where(item_category: category))
      monster_slot.push(player.monsterthree)
    end

    if monster_arr.size.positive?
      random = rand(0..monster_arr.size - 1)
      offset = rand(monster_arr[random].count)
      random_card_id = monster_arr[random].offset(offset).first.id

      Ingamedeck.where(card_id: random_card_id, cardable: monster_slot[random]).first&.update!(cardable: gameboard.graveyard)
    end
  end

  def self.lose_item(player, gameboard)
    monster_arr = []
    monster_slot = []
    if player.monsterone.cards.where(type: 'Itemcard').any?
      monster_arr.push(player.monsterone.cards.where(type: 'Itemcard'))
      monster_slot.push(player.monsterone)
    end
    if player.monstertwo.cards.where(type: 'Itemcard').any?
      monster_arr.push(player.monstertwo.cards.where(type: 'Itemcard'))
      monster_slot.push(player.monstertwo)
    end
    if player.monsterthree.cards.where(type: 'Itemcard').any?
      monster_arr.push(player.monsterthree.cards.where(type: 'Itemcard'))
      monster_slot.push(player.monsterthree)
    end

    if monster_arr.size.positive?
      random = rand(0..monster_arr.size - 1)
      offset = rand(monster_arr[random].count)
      random_card_id = monster_arr[random].offset(offset).first.id

      Ingamedeck.where(card_id: random_card_id, cardable: monster_slot[random]).first&.update!(cardable: gameboard.graveyard)
    end
  end

  def self.broadcast_gamelog(msg, gameboard)
    GameChannel.broadcast_to(gameboard, { type: 'GAME_LOG', params: { date: Time.new, message: msg, type: 'error' } })
  end

  def self.bad_things(ingamedeck, gameboard)
    player = gameboard.current_player

    case ingamedeck.card.action # get the action from card
    when 'lose_item_hand'
      lose_item_by_category(player, gameboard, 'hand')
      msg = "#{player.name} lost one hand item because of #{ingamedeck.card.title}s bad things."
      Monstercard.broadcast_gamelog(msg, gameboard)
    when 'lose_item_shoe'
      lose_item_by_category(player, gameboard, 'shoe')
      msg = "#{player.name} lost one shoe item because of #{ingamedeck.card.title}s bad things."
      Monstercard.broadcast_gamelog(msg, gameboard)
    when 'lose_item_head'
      lose_item_by_category(player, gameboard, 'head')
      msg = "#{player.name} lost one head item because of #{ingamedeck.card.title}s bad things."
      Monstercard.broadcast_gamelog(msg, gameboard)
    when 'lose_item'
      lose_item(player, gameboard)
      msg = "#{player.name} lost one item because of #{ingamedeck.card.title}s bad things."
      Monstercard.broadcast_gamelog(msg, gameboard)
    when 'random_card_lowest_level'
      all_players = gameboard.players.order(:id)
      first = true
      player_lowest_level = [player]

      all_players.each do |player_temp|
        if player_temp.id != player.id && player_temp.level <= player.level
          if first
            player_lowest_level = [player_temp]
            first = false
          else
            player_lowest_level = [player_temp] if player_lowest_level[0].level > player_temp.level
            player_lowest_level.push(player_temp) if player_lowest_level[0].level == player_temp.level
          end
        end
      end

      offset = rand(player.handcard.ingamedecks.count)

      random_card = player.handcard.ingamedecks.offset(offset).first

      random = rand(0..player_lowest_level.size - 1)

      random_card&.update!(cardable: player_lowest_level[random].handcard)
      msg = "#{player.name} lost one item to the player with the lowest level because of #{ingamedeck.card.title}s bad things."
      Monstercard.broadcast_gamelog(msg, gameboard)
      Player.broadcast_all_playerhandcards(gameboard)
    when 'no_help_next_fight'
      Ingamedeck.create(card: Cursecard.find_by('title = ?', 'The unicorn curse'), gameboard: gameboard, cardable: player.playercurse)

      msg = "No one is allowed to help #{player.name} in the next fight because of #{ingamedeck.card.title}s bad things."
      Monstercard.broadcast_gamelog(msg, gameboard)
    when 'lose_one_card'
      offset = rand(player.handcard.ingamedecks.count)

      random_card = player.handcard.ingamedecks.offset(offset).first

      random_card&.update!(cardable: gameboard.graveyard)
      msg = "#{player.name} lost one handcard because of #{ingamedeck.card.title}s bad things."
      Monstercard.broadcast_gamelog(msg, gameboard)
      Player.broadcast_all_playerhandcards(gameboard)
    when 'lose_level'
      player = gameboard.current_player

      player.update(level: player.level - 1) unless player.level == 1

      msg = "#{player.name} lost one level because of #{ingamedeck.card.title}s bad things."
      Monstercard.broadcast_gamelog(msg, gameboard)
    when 'die'
      player = gameboard.current_player

      player.update(level: 1)

      msg = "#{player.name} died because of #{ingamedeck.card.title}s bad things."
      Monstercard.broadcast_gamelog(msg, gameboard)
    else
      puts 'action unknown :('
    end
  end
end
