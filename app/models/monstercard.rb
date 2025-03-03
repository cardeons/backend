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
    # find "original" card, only advance if found
    if deck_card.nil?
      type = 'ERROR'
      message = '❌ Card not found. Something went wrong.'
      return { type: type, message: message }
    end

    card = Card.find_by('id=?', deck_card.card_id)

    # there already are 5 items, you can't put any more (6 because the monster itself is in this table)
    if monster_to_equip.cards.count == 6
      type = 'ERROR'
      message = "❌ You can't put any more items on this monster."

    # category already on monster
    elsif monster_to_equip.cards.where('item_category=?', card.item_category).count.positive?

      if card.item_category == 'hand' && monster_to_equip.cards.where('item_category=?', card.item_category).count == 1
        type = 'GAMEBOARD_UPDATE'
        message = '✅ Successfully equipped.'
        deck_card.update(cardable: monster_to_equip)

        # get update player atk
        player.calculate_player_atk_with_monster_and_items

      else
        type = 'ERROR'
        message = "❌ You already have this type of item on your monster! (#{card.item_category})"
      end
    # GameChannel.broadcast_to(gameboard, {type: 'ERROR', params: { message: "You already have this type of item on your monster! (#{card.item_category})" } })

    # not an item
    elsif  card.type != 'Itemcard'
      type = 'ERROR'
      message = "❌ Sorry, you can't put anything on your monster that is not an item!"
    # GameChannel.broadcast_to(gameboard, {type: 'ERROR', params: { message: "Sorry, you can't put anything on your monster that is not an item!"} })

    # yay
    else
      type = 'GAMEBOARD_UPDATE'
      deck_card.update(cardable: monster_to_equip)

      # update plaayer atk
      player.calculate_player_atk_with_monster_and_items

      message = '✅ Successfully equipped.'
    end

    # type = "equip"
    { type: type, message: message }
  end

  def self.calculate_monsterslot_atk(monsterslot)
    return 0 unless monsterslot

    monstercard = monsterslot.cards.find_by('type=?', 'Monstercard')

    monster_items_atk_points = 0

    # monster always have 1 attack if player plays them
    monster_items_atk_points = 1 if monstercard

    itemcards = monsterslot.cards.where(type: 'Itemcard')
    monster_items_atk_points += itemcards.sum(:atk_points)

    itemcards.where.not(synergy_type: nil).each do |card|
      # calculate synergy of item with given monstercard
      monster_items_atk_points += card.calculate_synergy_value(monstercard)

      # calculate synergy with the other items!
      itemcards.each do |card_to_compare|
        monster_items_atk_points += card.calculate_synergy_value(card_to_compare)
      end
    end

    monster_items_atk_points
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

  def self.random_to_lowest(player, gameboard)
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
  end

  def self.lose_level(player, gameboard, ingamedeck)
    if gameboard.reload.intercept_finished?
      player.decrement!(:level, 1) unless player.level == 1
      msg = "😢 #{player.name} lost one level because of #{ingamedeck.card.title}s bad things."
      Monstercard.broadcast_gamelog(msg, gameboard)
    else
      gameboard.boss_phase_finished!
      GameChannel.broadcast_to(gameboard, { type: 'BOARD_UPDATE', params: Gameboard.broadcast_game_board(gameboard.reload) })

      msg = "❌ Too bad. Even together you couldn't defeat the monster. You all lost a level."
      Monstercard.broadcast_gamelog(msg, gameboard)

      gameboard.reload.players.each do |player_individual|
        player_individual.decrement!(:level, 1) unless player_individual.level == 1
      end

      gameboard.centercard.ingamedeck&.update!(cardable: gameboard.graveyard)

      # sleep for frontend animation
      # could maybe be shorter as soon as we know the animation length (kinda)
      sleep 2

      Gameboard.get_next_player(gameboard)
      gameboard.ingame!
      GameChannel.broadcast_to(gameboard, { type: 'BOARD_UPDATE', params: Gameboard.broadcast_game_board(gameboard.reload) })
    end
  end

  def self.bad_things(ingamedeck, gameboard)
    player = gameboard.current_player

    case ingamedeck.card.action # get the action from card
    when 'lose_item_hand'
      lose_item_by_category(player, gameboard, 'hand')
      msg = "😢 #{player.name} lost one hand item because of #{ingamedeck.card.title}s bad things."
      Monstercard.broadcast_gamelog(msg, gameboard)
    when 'lose_item_shoe'
      lose_item_by_category(player, gameboard, 'shoe')
      msg = "😢 #{player.name} lost one shoe item because of #{ingamedeck.card.title}s bad things."
      Monstercard.broadcast_gamelog(msg, gameboard)
    when 'lose_item_head'
      lose_item_by_category(player, gameboard, 'head')
      msg = "😢 #{player.name} lost one head item because of #{ingamedeck.card.title}s bad things."
      Monstercard.broadcast_gamelog(msg, gameboard)
    when 'lose_item'
      lose_item(player, gameboard)
      msg = "😢 #{player.name} lost one item because of #{ingamedeck.card.title}s bad things."
      Monstercard.broadcast_gamelog(msg, gameboard)
    when 'random_card_lowest_level'
      random_to_lowest(player, gameboard)
      msg = "😢 #{player.name} lost one item to the player with the lowest level because of #{ingamedeck.card.title}s bad things."
      Monstercard.broadcast_gamelog(msg, gameboard)
      Player.broadcast_all_playerhandcards(gameboard)
    when 'no_help_next_fight'
      Ingamedeck.create(card: Cursecard.find_by('title = ?', 'The unicorn curse'), gameboard: gameboard, cardable: player.playercurse)

      msg = "😢 No one is allowed to help #{player.name} in the next fight because of #{ingamedeck.card.title}s bad things."
      Monstercard.broadcast_gamelog(msg, gameboard)
    when 'lose_one_card'
      offset = rand(player.handcard.ingamedecks.count)
      random_card = player.handcard.ingamedecks.offset(offset).first
      random_card&.update!(cardable: gameboard.graveyard)
      msg = "😢 #{player.name} lost one handcard because of #{ingamedeck.card.title}s bad things."
      Monstercard.broadcast_gamelog(msg, gameboard)
      Player.broadcast_all_playerhandcards(gameboard)
    when 'lose_level'
      lose_level(player, gameboard, ingamedeck)
    when 'die'
      player.update(level: 1)

      msg = "💀 #{player.name} died because of #{ingamedeck.card.title}s bad things."
      Monstercard.broadcast_gamelog(msg, gameboard)
    when 'no_action'
      msg = "🤷‍♀️ #{player.name} was lucky #{ingamedeck.card.title} is too bored to do anything about him."
      Monstercard.broadcast_gamelog(msg, gameboard)
    else
      puts '❌ action unknown'
    end
  end
end
