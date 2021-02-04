# frozen_string_literal: true

require 'pp'

class Gameboard < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :ingamedeck, dependent: :destroy
  has_one :player, foreign_key: 'current_player'
  has_one :centercard

  # has_many :cards, through: :ingame_cards

  def self.initialize_game_board(gameboard)
    gameboard.update(current_player: gameboard.players.last.id, current_state: 'started')
    # Gameboard.find(gameboard.id).save
    Centercard.create(gameboard_id: gameboard.id)
    Graveyard.create!(gameboard_id: gameboard.id)

    gameboard.players.each do |player|
      # Player.draw_five_cards(player)

      Handcard.create(player_id: player.id) unless player.handcard
      Handcard.draw_handcards(player.id, gameboard)
    end
  end

  def self.broadcast_game_board(gameboard)
    players_array = []

    gameboard = Gameboard.find(gameboard.id)



    gameboard.players.each do |player|
      # ##only for debug
      # TODO: remove later
      Inventory.create(player: player) unless player.inventory

      Handcard.create(player: player) unless player.handcard

      Monsterone.create(player: player) unless player.monsterone

      Monstertwo.create(player: player) unless player.monstertwo

      Monsterthree.create(player: player) unless player.monsterthree

      Playercurse.create(player: player) unless player.playercurse

      monsters = []

      if player.monsterone.ingamedecks&.first
        monsters.push(
          renderUserMonsters(player, 'Monsterone')
        )
      end
      if player.monstertwo.ingamedecks&.first
        monsters.push(
          renderUserMonsters(player, 'Monstertwo')
        )
      end
      if player.monsterthree.ingamedecks&.first
        monsters.push(
          renderUserMonsters(player, 'Monsterthree')
        )
      end

      players_array.push({ name: player.name, player_id: player.id, inventory: renderCardId(player.inventory.ingamedecks), level: player.level, attack: player.attack,
                           handcard: player.handcard.cards.count, monsters: monsters, playercurse: renderCardId(player.playercurse.ingamedecks), user_id: player.user.id })
    end

    pp 'ggggggggggggggggggggggggggggggggggg'
    pp output = { # add center
      # graveyard: gameboard.graveyard,
      players: players_array,
      # needs more info
      gameboard: renderGameboard(gameboard)
    }

    output = { # add center
      # graveyard: gameboard.graveyard,
      players: players_array,
      # needs more info
      gameboard: renderGameboard(gameboard)
    }
  end

  # render cards for frontend
  def self.renderCardId(cards)
    cardArray = []

    cards.each do |card|
      cardArray.push({ unique_card_id: card.id, card_id: card.card_id })
    end
    cardArray
  end

  def self.renderUserMonsters(player, monsterslot)
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

    pp "***********************************************++"
    # pp monster.ingamedecks.first

    if monster.ingamedecks.count > 0
      unique_monster_id = monster.ingamedecks[0].id
      monster_id = monster.ingamedecks[0].card_id

      monster.ingamedecks.each do |ingamedeck|

        pp "********************************************-----"
        pp monster.ingamedecks
        pp ingamedeck.card
        pp ingamedeck.card.type

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

  def self.renderCardFromId(id)

    pp "**************************"
    pp id

    if Ingamedeck.find_by('id = ?', id)
      card = Ingamedeck.find(id)
      { unique_card_id: card.id, card_id: card.card_id }
    end
  end

  def self.renderGameboard(gameboard)

    pp gameboard
    pp gameboard.centercard
    pp gameboard.centercard.ingamedecks

    if gameboard.centercard.ingamedecks.any?
      centercard = gameboard.centercard.ingamedecks.first.id
    else 
      centercard = []
    end

    {
      gameboard_id: gameboard.id,
      current_player: gameboard.current_player,
      center_card: centercard,
      interceptcards: [],
      player_atk: gameboard.player_atk,
      monster_atk: gameboard.monster_atk,
      success: gameboard.success,
      can_flee: gameboard.can_flee,
      rewards_treasure: gameboard.rewards_treasure
    }
  end

  def self.get_next_player(gameboard)
    gameboard = Gameboard.find(gameboard.id)
    players = gameboard.players
    current_player = gameboard.current_player
    count = gameboard.players.count

    #search for the index player with this index 
    index_of_player = players.find_index{ |player| player.id == current_player}

    #index of gameboard.players
    index_of_next_player = index_of_player + 1
    
    #if index is bigger than player count start with first player
    if index_of_next_player > count -1
      index_of_next_player = 0
    end

    #get the next Player from array of players
    next_player = gameboard.players[index_of_next_player]

    # save it to gameboard
    gameboard.current_player = next_player.id
    gameboard.save!
  end

  def self.draw_door_card(gameboard)
    cursecards = Cursecard.all
    monstercards = Monstercard.all
    bosscards = Bosscard.all

    allcards = []
    # addCardsToArray(allcards, cursecards)
    addCardsToArray(allcards, monstercards)
    # addCardsToArray(allcards, bosscards)

    randomcard = allcards[rand(allcards.length)]

    centercard = Centercard.find_by('gameboard_id = ?', gameboard.id)

    centercard.ingamedecks.each do |ingamedeck|
      ingamedeck.update(cardable: Graveyard.find_by('gameboard_id = ?', gameboard.id))
    end

    ingamecard = Ingamedeck.create(gameboard: gameboard, card_id: randomcard, cardable: Centercard.find_by('gameboard_id = ?', gameboard.id))

    gameboard.update(centercard: Centercard.find_by('gameboard_id = ?', gameboard.id), rewards_treasure: Card.find_by('id = ?', randomcard).rewards_treasure)

    gameboard.centercard.cards.first.title
  end

  def self.addCardsToArray(arr, cards)
    cards.each do |card|
      x = card.draw_chance
      while x.positive?
        arr.push card.id
        x -= 1
      end
    end
  end

  def self.flee(gameboard)
    roll = rand(1..6)
    output = {}
    if roll > 4
      gameboard.update(can_flee: true)
      output = {
        flee: true,
        value: roll
      }
    else
      gameboard.update(can_flee: false)
      output = {
        flee: false,
        value: roll
      }
    end

    output
  end

  def self.attack(gameboard)
    monsterid = gameboard.centercard.cards.first.id
    playerid = gameboard.current_player

    monstercards1 = Player.find(playerid).monsterone.cards.sum(:atk_points)
    monstercards2 = Player.find(playerid).monstertwo.cards.sum(:atk_points)
    monstercards3 = Player.find(playerid).monsterthree.cards.sum(:atk_points)

    playeratkpoints = monstercards1 + monstercards2 + monstercards3 + Player.find(playerid).level

    monsteratkpts = Monstercard.find_by("id=?", monsterid).atk_points

    playerwin = playeratkpoints > monsteratkpts


    if playerwin
      message = "SUCCESS"
      gameboard.update(success: true, player_atk: playeratkpoints, monster_atk: monsteratkpts)
    puts "playerwin"
    else
      message = "FAIL"
      gameboard.update(success: false, player_atk: playeratkpoints, monster_atk: monsteratkpts)
      # broadcast: flee or use cards!
      puts "monsterwin"
    end

    message
  end 
end
