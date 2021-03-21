# frozen_string_literal: true

class Gameboard < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :ingamedeck, dependent: :destroy
  has_one :player, foreign_key: 'current_player'
  has_one :centercard, dependent: :destroy
  has_one :graveyard, dependent: :destroy
  has_one :interceptcard, dependent: :destroy
  has_one :playerinterceptcard, dependent: :destroy
  enum current_state: %i[lobby ingame]

  # has_many :cards, through: :ingame_cards

  def initialize_game_board
    current_player = players.last.id
    gameboard_id = id
    update(current_player: current_player, current_state: 'ingame')
    Centercard.create!(gameboard_id: gameboard_id)
    Graveyard.create!(gameboard_id: gameboard_id)
    Playerinterceptcard.create!(gameboard_id: gameboard_id)
    Interceptcard.create!(gameboard_id: gameboard_id)

    players.each do |player|
      Handcard.find_or_create_by!(player_id: player.id) # unless player.handcard
      Handcard.draw_handcards(player.id, self)
    end
  end

  def self.broadcast_game_board(gameboard)
    players_array = []

    gameboard = Gameboard.find(gameboard.id)

    gameboard.players.each do |player|
      players_array.push(player.render_player)
    end

    {
      # graveyard: gameboard.graveyard,
      players: players_array,
      gameboard: render_gameboard(gameboard)
    }
  end

  # render cards for frontend
  def self.render_cards_array(cards)
    card_array = []

    cards.each do |card|
      card_array.push({ unique_card_id: card.id, card_id: card.card_id })
    end
    card_array
  end

  def self.render_user_monsters(player, monsterslot)
    monster = case monsterslot
              when 'Monsterone'
                player.monsterone
              when 'Monstertwo'
                player.monstertwo
              else
                player.monsterthree
              end

    items = []

    output = []

    # pp monster.ingamedecks
    if monster.ingamedecks.count.positive?

      unique_monster_id = monster.ingamedecks[0].id
      monster_id = monster.ingamedecks[0].card_id

      monster.ingamedecks.each do |ingamedeck|
        if ingamedeck.card.type == 'Monstercard'
          unique_monster_id = ingamedeck.id
          monster_id = ingamedeck.card_id

        else
          items.push({ unique_card_id: ingamedeck.id, card_id: ingamedeck.card_id })
        end
      end

      output = {
        unique_card_id: unique_monster_id,
        card_id: monster_id,
        item: items
      }
    end
    output
  end

  def self.render_card_from_id(id)
    card = Ingamedeck.find_by!('id = ?', id)
    { unique_card_id: card.id, card_id: card.card_id }
  end

  def self.render_gameboard(gameboard)
    # TODO: check if this selects the right card
    centercard = (render_card_from_id(gameboard.centercard.ingamedecks.first.id) if gameboard.centercard.ingamedecks.any?)
    {
      gameboard_id: gameboard.id,
      current_player: gameboard.current_player,
      center_card: centercard,
      # TODO: intercept cards are missing
      interceptcards: [],
      player_atk: gameboard.player_atk,
      monster_atk: gameboard.monster_atk,
      success: gameboard.success,
      can_flee: gameboard.can_flee,
      rewards_treasure: gameboard.rewards_treasure
    }
  end

  def self.get_next_player(gameboard)
    gameboard = Gameboard.find_by('id = ?', gameboard.id)
    players = gameboard.players
    current_player_id = gameboard.current_player

    count = players.count

    # search for the index player with this index
    index_of_player = players.find_index { |player| player.id == current_player_id }

    # if index is bigger than player count start with first player
    index_of_next_player = (index_of_player + 1) % count

    # get the next Player from array of players
    next_player = gameboard.players[index_of_next_player]

    # save it to gameboard
    gameboard.current_player = next_player.id
    gameboard.save!

    next_player
  end

  def self.draw_door_card(gameboard)
    # cursecards = Cursecard.all
    monstercards = Monstercard.all
    # bosscards = Bosscard.all

    allcards = []
    # addCardsToArray(allcards, cursecards)
    add_cards_to_array(allcards, monstercards)
    # addCardsToArray(allcards, bosscards)

    randomcard = allcards[rand(allcards.length)]

    centercard = Centercard.find_by!('gameboard_id = ?', gameboard.id)

    centercard.ingamedecks.each do |ingamedeck|
      ingamedeck.update!(cardable: gameboard.graveyard)
    end

    # centercard
    Ingamedeck.create(gameboard: gameboard, card_id: randomcard, cardable: centercard)

    attack_obj = attack(gameboard)

    new_center = Centercard.find_by('gameboard_id = ?', gameboard.id)
    new_treasure = Card.find_by('id = ?', randomcard).rewards_treasure

    gameboard.update(centercard: new_center, success: attack_obj[:result], player_atk: attack_obj[:playeratk], monster_atk: attack_obj[:monsteratk],
                     rewards_treasure: new_treasure)

    gameboard.centercard.cards.first.title
  end

  def self.flee(gameboard)
    roll = rand(1..6)
    output = {}

    if roll > 4
      gameboard.update!(can_flee: true)
      output = {
        flee: true,
        value: roll
      }
    else
      gameboard.update!(can_flee: false)
      output = {
        flee: false,
        value: roll
      }
    end

    output
  end

  def self.attack(gameboard)
    playerid = gameboard.current_player
    playeratkpoints = 1

    unless playerid.nil?

      player = Player.find_by('id=?', playerid)

      monstercards1 = player.monsterone.nil? ? 0 : player.monsterone.cards.sum(:atk_points)

      monstercards2 = player.monstertwo.nil? ? 0 : player.monstertwo.cards.sum(:atk_points)

      monstercards3 = player.monsterthree.nil? ? 0 : player.monsterthree.cards.sum(:atk_points)

      playeratkpoints = monstercards1 + monstercards2 + monstercards3 + player.level

      playeratkpoints += gameboard.playerinterceptcard.cards.sum(:atk_points)

      ## monsteratk points get set to 0 if cards.first is nil => no centercard
      monsteratkpts = gameboard.centercard.cards.first&.atk_points || 0

      # #add intercept buffs
      monsteratkpts += gameboard.interceptcard.cards.sum(:atk_points)

      playerwin = playeratkpoints > monsteratkpts

      if playerwin
        #   message = "SUCCESS"
        gameboard.update(success: true, player_atk: playeratkpoints, monster_atk: monsteratkpts)
        puts 'playerwin'
      else
        #   message = "FAIL"
        gameboard.update(success: false, player_atk: playeratkpoints, monster_atk: monsteratkpts)
        #   # broadcast: flee or use cards!
        puts 'monsterwin'
      end

    end

    { result: playerwin, playeratk: playeratkpoints, monsteratk: monsteratkpts }
  end

  def self.reset_all_game_boards
    Ingamedeck.all.where(cardable_type: 'Centercard').destroy_all

    Gameboard.all.each do |gameboard|
      player_id_current = gameboard.current_player

      next unless player_id_current

      current_player = Player.find_by!('id=?', player_id_current)
      current_player.handcard.ingamedecks.delete_all

      current_player.inventory.ingamedecks.delete_all if current_player.inventory&.ingamedecks

      current_player.monsterone.ingamedecks.delete_all if current_player.monsterone&.ingamedecks

      current_player.monstertwo.ingamedecks.delete_all if current_player.monstertwo&.ingamedecks

      current_player.monsterthree.ingamedecks.delete_all if current_player.monsterthree&.ingamedecks

      gameboard.update_attribute(:player_atk, 1)

      Handcard.draw_handcards(current_player.id, gameboard)

      # updated_board = Gameboard.broadcast_game_board(gameboard)
      # GameChannel.broadcast_to(gameboard, { type: "BOARD_UPDATE", params: updated_board })
      # PlayerChannel.broadcast_to(current_player.user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.renderCardId(current_player.handcard.ingamedecks) } })
    end
  end

  def self.add_cards_to_array(arr, cards)
    cards.each do |card|
      x = card.draw_chance
      while x.positive?
        arr.push card.id
        x -= 1
      end
    end
  end
end
