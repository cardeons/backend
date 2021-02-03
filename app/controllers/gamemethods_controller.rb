# frozen_string_literal: true

class GamemethodsController < ApplicationController

  def equip_monster
    
    #TODO frontend schickt player und unique card_id und monsterslot
    player = Player.find(params[:player_id])
    gameboard_id = params[:gameboard_id]
    card_id = params[:deck_id]
    monsterslot = params[:monsterslot]

    #define which monster
    case monsterslot
    when "Monsterone"
      monster_to_equip = player.monsterone
    when "Monstertwo"
      monster_to_equip = player.monstertwo
    else
      monster_to_equip = player.monsterthree
    end

    #find ingamedeck card (gameboard_id nur zusatz, wenn vom frontend unique id kommt sollte mans nicht brauchen)
    deck_card = Ingamedeck.find_by("id=? AND gameboard_id=?", card_id, gameboard_id)

  #find "original" card, only advance if found
    unless deck_card.nil?
      card = Card.find_by("id=?", deck_card.card_id)

    #TODO validieren
      cardtype = card.type

      # there already are 5 items, you can't put any mor (6 because the monster itself is in this table)
      if monster_to_equip.cards.count == 6
          puts "**************"
          error_message = "sorry you can't put any more items on this monster"
      # category already on monster
      elsif monster_to_equip.cards.where("item_category=?", card.item_category).count > 0
          puts "**************"
          error_message = "nono not allowed, you already have " + card.item_category
      # not an item
      elsif cardtype != "Itemcard"
          puts "**************"
          error_message = "sorry you can't put anything on your monster that's not an item"
      # yay
      else
          puts "************** created Card *************"
          deck_card.update_attribute(:cardable_type, monsterslot)
          puts "************** created Card *************"
          error_message = "no problem"
      end
    end

    if error_message.nil?
      error_message = "Something went wrong with finding the card"
    end

    player_atk = monster_to_equip.cards.sum(:atk_points)
    render json: { card_to_add: card, result: error_message, akt_points: player_atk, player_cards: monster_to_equip.cards }, status: 200

  end

  def draw_doorcard
    cursecards = Cursecard.all
    monstercards = Monstercard.all
    bosscards = Bosscard.all

    allcards = []
    addCardsToArray(allcards, cursecards)
    addCardsToArray(allcards, monstercards)
    addCardsToArray(allcards, bosscards)

    randomcard = allcards[rand(allcards.length)]

    render json: { card: randomcard }, status: 200
  end

  def draw_treasurecard
    cursecards = Cursecard.all
    monstercards = Monstercard.all
    buffcards = Buffcard.all
    itemcards = Itemcard.all
    levelcards = Levelcard.all

    allcards = []
    addCardsToArray(allcards, cursecards)
    addCardsToArray(allcards, monstercards)
    addCardsToArray(allcards, buffcards)
    addCardsToArray(allcards, itemcards)
    addCardsToArray(allcards, levelcards)

    randomcard = allcards[rand(allcards.length)]

    render json: { card: randomcard }, status: 200
  end

  def draw_handcards
    cursecards = Cursecard.all
    monstercards = Monstercard.all
    buffcards = Buffcard.all
    itemcards = Itemcard.all
    levelcards = Levelcard.all

    allcards = []
    addCardsToArray(allcards, cursecards)
    addCardsToArray(allcards, monstercards)
    addCardsToArray(allcards, buffcards)
    addCardsToArray(allcards, itemcards)
    addCardsToArray(allcards, levelcards)

    handcard = Player.find(params[:id]).handcard

    Ingamedeck.where(cardable_type: 'Handcard', cardable_id: handcard.id).delete_all
    x = 5
    # die x variable ändern je nachdem wie viele Karten Spieler mit ins Game nimmt :)
    while x.positive?
      Ingamedeck.create(gameboard_id: params[:gameboard_id], card_id: allcards[rand(allcards.length)], cardable_id: handcard.id, cardable_type: 'Handcard')
      x -= 1
    end

    render json: { card: handcard.cards }, status: 200
  end

  def addCardsToArray(arr, cards)
    cards.each do |card|
      x = card.draw_chance
      while x.positive?
        arr.push card.id
        x -= 1
      end
    end
  end

  def canFlee?
    render json: rand(6) > 3
  end

  def attack(monsterslot = 3, monsterid = params[:monsterid], playerid = params[:playerid])
    monstercards = Player.find(playerid).monsterthree.cards

    case monsterslot
    when 1
      monstercards = Player.find(playerid).monsterone.cards
    when 2
      monstercards = Player.find(playerid).monstertwos.cards
    end

    playeratkpts = 0

    monstercards.each do |card|
      playeratkpts += card.atk_points
    end

    monsteratkpts = Monstercard.find(monsterid).atk_points

    playerwin = playeratkpts > monsteratkpts

    if playerwin
    # broadcast: start interceptionface
    else
      # broadcast: flee or use cards!
    end

    render json:
    {
      player_id: playerid,
      monster_id: monsterid,
      playermonster: monstercards,
      totalplayeratk: playeratkpts,
      monsteratk: monsteratkpts,
      playerwin: playerwin
    }
  end
end
