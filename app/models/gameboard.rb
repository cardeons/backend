# frozen_string_literal: true

class Gameboard < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :ingamedeck, dependent: :destroy
  has_one :player, foreign_key: 'current_player'
  has_one :centercard, dependent: :destroy
  has_one :graveyard, dependent: :destroy
  has_one :interceptcard, dependent: :destroy
  has_one :playerinterceptcard, dependent: :destroy
  enum current_state: %i[lobby ingame intercept_phase intercept_finished]

  # has_many :cards, through: :ingame_cards

  def initialize_game_board
    current_player = players.last.id
    gameboard_id = id
    update(current_player: current_player, current_state: 'ingame')
    Centercard.create!(gameboard_id: gameboard_id)
    Graveyard.create!(gameboard_id: gameboard_id)
    Playerinterceptcard.create!(gameboard_id: gameboard_id)
    Interceptcard.create!(gameboard_id: gameboard_id)

    # only select ids, not whole model
    playerIds = Player.where(gameboard_id: gameboard_id).pluck(:id)

    playerIds.each do |player|
      Handcard.find_or_create_by!(player_id: player) # unless player.handcard
      Handcard.draw_handcards(player, self)
    end
  end

  def self.broadcast_game_board(gameboard)
    players_array = []

    gameboard = Gameboard.find_by("id = ?", gameboard.id)

    gameboard.players.each do |player|
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

    # pp cards
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
      current_player: gameboard.current_player,
      center_card: centercard,
      interceptcards: render_cards_array(gameboard.interceptcard&.ingamedecks),
      player_interceptcards: render_cards_array(gameboard.playerinterceptcard&.ingamedecks),
      player_atk: gameboard.player_atk,
      monster_atk: gameboard.monster_atk,
      success: gameboard.success,
      can_flee: gameboard.can_flee,
      intercept_timestamp: gameboard.intercept_timestamp,
      current_state: gameboard.current_state,
      rewards_treasure: gameboard.rewards_treasure,
      graveyard: render_cards_array(gameboard.graveyard.ingamedecks)
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
    gameboard.intercept_phase!
    # cursecards = Cursecard.all

    ## only select id and draw chance, add_cards_to_array doesn't need the whole model
    ## returns  e.g. [3(id), 1(draw_chance)]
    monstercards = Monstercard.pluck(:id, :draw_chance)
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


    attack_obj = attack(gameboard.reload)

    gameboard.update(success: attack_obj[:result], player_atk: attack_obj[:playeratk], monster_atk: attack_obj[:monsteratk])

    gameboard.players.each do |player|
      player.update!(intercept: true)
    end

    gameboard.centercard.card.title
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

    # TODO: add bad things if flee does not succeed
    get_next_player(gameboard)

    output
  end

  def self.attack(gameboard)
    gameboard.reload
    playerid = gameboard.current_player
    playeratkpoints = 1

    unless playerid.nil?

      player = Player.find_by('id=?', playerid)

      ## with joins - way slower!!
      # player = Player.includes(monsterone: [:cards], monstertwo: [:cards], monsterthree: [:cards]).find_by('id=?', playerid)
      # playeratkpoints = player.monsterone.cards.sum(:atk_points) + player.monstertwo.cards.sum(:atk_points) + player.monsterthree.cards.sum(:atk_points) + player.level + gameboard.helping_player_atk

      # gameboard_cards = Gameboard.includes(interceptcard: [:cards], centercard: [:card], playerinterceptcard: [:cards]).find(gameboard.id)
      # playeratkpoints += gameboard_cards.playerinterceptcard.cards.sum(:atk_points)


      monstercards1 = player.monsterone.nil? ? 0 : player.monsterone.cards.sum(:atk_points)

      monstercards2 = player.monstertwo.nil? ? 0 : player.monstertwo.cards.sum(:atk_points)

      monstercards3 = player.monsterthree.nil? ? 0 : player.monsterthree.cards.sum(:atk_points)

      playeratkpoints = monstercards1 + monstercards2 + monstercards3 + player.level + gameboard.helping_player_atk

      playeratkpoints += gameboard.playerinterceptcard.cards.sum(:atk_points)

      ## monsteratk points get set to 0 if cards.first is nil => no centercard
      monsteratkpts = gameboard.centercard.card&.atk_points || 0

      # #add intercept buffs
      monsteratkpts += gameboard.interceptcard.cards.sum(:atk_points)

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

    ## only current player id needed
    all_current_players = Gameboard.all.pluck(:current_player)

    all_current_players.each do |gameboard|
      player_id_current = gameboard

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
      # pp card
      x = card[1]
      while x.positive?
        arr.push card[0]
        x -= 1
      end
    end
  end
end
