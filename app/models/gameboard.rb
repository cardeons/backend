# frozen_string_literal: true

class Gameboard < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :ingamedeck, dependent: :destroy
  # has_one :player, foreign_key: 'current_player'
  belongs_to :current_player, class_name: 'Player', foreign_key: 'player_id', optional: true
  belongs_to :helping_player, class_name: 'Player', foreign_key: 'helping_player_id', optional: true
  has_one :centercard, dependent: :destroy
  has_one :graveyard, dependent: :destroy
  has_one :interceptcard, dependent: :destroy
  has_one :playerinterceptcard, dependent: :destroy
  enum current_state: %i[lobby ingame intercept_phase intercept_finished game_won]

  # has_many :cards, through: :ingame_cards

  def initialize_game_board
    current_player = players.last
    gameboard_id = id
    update(current_player: current_player, current_state: 'ingame')
    Centercard.create!(gameboard_id: gameboard_id)
    Graveyard.create!(gameboard_id: gameboard_id)
    Playerinterceptcard.create!(gameboard_id: gameboard_id)
    Interceptcard.create!(gameboard_id: gameboard_id)

    # pp Player.find(current_player).gameboard
    players.each do |player|
      Handcard.find_or_create_by!(player_id: player.id) # unless player.handcard
      Handcard.draw_handcards(player.id, self, 4)
      Handcard.draw_one_monster(player.id, self)
    end
  end

  def self.broadcast_game_board(gameboard)
    players_array = []

    gameboard = Gameboard.find(gameboard.id)

    gameboard.players.order(:id).each do |player|
      players_array.push(player.reload.render_player)
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

    # return nil if cards are empty
    return nil unless cards

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
    gameboard = gameboard.reload

    centercard = (render_card_from_id(gameboard.centercard.ingamedeck.id) if gameboard.centercard.ingamedeck)
    {
      gameboard_id: gameboard.id,
      current_player: gameboard.current_player&.id,
      center_card: centercard,
      interceptcards: render_cards_array(gameboard.interceptcard&.ingamedecks),
      player_interceptcards: render_cards_array(gameboard.playerinterceptcard&.ingamedecks),
      player_atk: gameboard.player_atk + gameboard.helping_player_atk,
      monster_atk: gameboard.monster_atk,
      success: gameboard.success,
      can_flee: gameboard.can_flee,
      intercept_timestamp: gameboard.intercept_timestamp,
      current_state: gameboard.current_state,
      rewards_treasure: gameboard.rewards_treasure,
      graveyard: render_cards_array(gameboard.graveyard.ingamedecks),
      shared_reward: gameboard.shared_reward,
      helping_player: gameboard.helping_player&.id
    }
  end

  def self.get_next_player(gameboard)
    gameboard = Gameboard.find_by('id = ?', gameboard.id)
    players = gameboard.players.order(:id)
    current_player_id = gameboard.current_player.id

    gameboard.current_player.reload.playercurse.ingamedecks.each do |ingamedeck|
      ingamedeck.update(cardable: gameboard.graveyard) unless ingamedeck.card.action == 'lose_atk_points'
    end

    # search for the index player with this index
    index_of_player = players.find_index { |player| player.id == current_player_id }

    count = players.count
    # if index is bigger than player count start with first player
    index_of_next_player = (index_of_player + 1) % count

    # get the next Player from array of players
    next_player = players[index_of_next_player]

    gameboard.update(asked_help: false, helping_player: nil, helping_player_atk: 0, shared_reward: 0)

    # save it to gameboard
    gameboard.current_player = next_player
    gameboard.save!

    next_player
  end

  def self.draw_door_card(gameboard)
    gameboard.intercept_phase!
    # cursecards = Cursecard.all
    monstercards = Monstercard.all
    # bosscards = Bosscard.all

    allcards = []
    # addCardsToArray(allcards, cursecards)
    add_cards_to_array(allcards, monstercards)
    # addCardsToArray(allcards, bosscards)

    randomcard = allcards[rand(allcards.size)]

    centercard = Centercard.find_by!('gameboard_id = ?', gameboard.id)

    # centercard.ingamedecks.each do |ingamedeck|
    #   ingamedeck.update!(cardable: gameboard.graveyard)
    # end

    centercard.ingamedeck&.update!(cardable: gameboard.graveyard)

    # centercard
    Ingamedeck.create(gameboard: gameboard, card_id: randomcard, cardable: centercard)

    new_center = Centercard.find_by('gameboard_id = ?', gameboard.id)
    new_treasure = Card.find_by('id = ?', randomcard).rewards_treasure

    gameboard.update(centercard: new_center, rewards_treasure: new_treasure)

    attack_obj = attack(gameboard.reload, true)

    gameboard.update(success: attack_obj[:result], player_atk: attack_obj[:playeratk], monster_atk: attack_obj[:monsteratk])

    gameboard.players.each do |player|
      player.update!(intercept: true)
    end

    gameboard.centercard.card.title
  end

  def self.flee(gameboard, current_user)
    roll = rand(1..6)

    output = {}

    if roll > 4
      gameboard.update!(can_flee: true)
      output = {
        flee: true,
        value: roll,
        player_name: current_user.name
      }
    else
      gameboard.update!(can_flee: false)
      Monstercard.bad_things(gameboard.centercard, gameboard)

      output = {
        flee: false,
        value: roll,
        player_name: current_user.name
      }
    end

    # TODO: add bad things if flee does not succeed
    get_next_player(gameboard)
    clear_buffcards(gameboard)
    output
  end

  def self.attack(gameboard, _curse_log = true)
    gameboard.reload
    player = gameboard.current_player
    playeratkpoints = 1

    unless player.nil?

      monstercards1 = Monstercard.calculate_monsterslot_atk(player.monsterone)
      monstercards2 = Monstercard.calculate_monsterslot_atk(player.monstertwo)
      monstercards3 = Monstercard.calculate_monsterslot_atk(player.monsterthree)

      playeratkpoints = monstercards1 + monstercards2 + monstercards3 + player.level + gameboard.helping_player_atk

      playeratkpoints += gameboard.playerinterceptcard.cards.sum(:atk_points)

      ## monsteratk points get set to 0 if cards.first is nil => no centercard
      monsteratkpts = gameboard.centercard.card&.atk_points || 0

      # #add intercept buffs
      monsteratkpts += gameboard.interceptcard.cards.sum(:atk_points)

      player.playercurse.ingamedecks.each do |curse|
        curse_obj = Cursecard.activate(curse, player, gameboard, playeratkpoints, monsteratkpts)

        playeratkpoints = curse_obj[:playeratk]
        monsteratkpts = curse_obj[:monsteratk]
      end

      playerwin = playeratkpoints > monsteratkpts

      if playerwin
        #   message = "SUCCESS"
        gameboard.update(success: true, player_atk: playeratkpoints, monster_atk: monsteratkpts)
      else
        #   message = "FAIL"
        gameboard.update(success: false, player_atk: playeratkpoints, monster_atk: monsteratkpts)
        #   # broadcast: flee or use cards!
      end

    end

    { result: playerwin, playeratk: playeratkpoints, monsteratk: monsteratkpts }
  end

  def self.reset_all_game_boards
    Ingamedeck.all.where(cardable_type: 'Centercard').destroy_all

    Gameboard.all.each do |gameboard|
      current_player = gameboard.current_player

      next unless current_player

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

  def self.clear_buffcards(gameboard)
    if gameboard.interceptcard
      gameboard.interceptcard.ingamedecks.each do |card|
        card.update!(cardable: gameboard.graveyard)
      end
    end

    if gameboard.playerinterceptcard
      gameboard.playerinterceptcard.ingamedecks.each do |card|
        card.update!(cardable: gameboard.graveyard)
      end
    end
  end
end
