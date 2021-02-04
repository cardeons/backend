# frozen_string_literal: true

class GamemethodsController < ApplicationController

  def draw_random_lvl_one
    monstercards = Monstercard.all.where('level=?', 1).pluck(:id).sample

    render json: { card: Monstercard.find(monstercards) }, status: 200
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

    # Ingamedeck.where(cardable_type: 'Handcard', cardable_id: handcard.id).delete_all

    # TODO: draw lvl one card if no Inventory cards
    # TODO die x variable ändern je nachdem wie viele Karten Spieler mit ins Game nimmt :)
    # TODO bei keiner mitgenommenen Karte random lvl one als monsterone, ansonsten Handkarten
    x = 5
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

  def attack(monsterid = params[:monsterid], playerid = params[:playerid])
    monstercards1 = Player.find(playerid).monsterone.cards
    monstercards2 = Player.find(playerid).monstertwo.cards
    monstercards3 = Player.find(playerid).monsterthree.cards

    temparr = []

    addAtkPts(temparr, monstercards1)
    addAtkPts(temparr, monstercards2)
    addAtkPts(temparr, monstercards3)

    playeratkpts = 0

    temparr.each do |item|
      playeratkpts += item
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

      playermonster: monstercards1,
      playermonster2: monstercards2,
      playermonster3: monstercards3,

      totalplayeratk: playeratkpts,
      monsteratk: monsteratkpts,
      playerwin: playerwin
    }
  end

  def addAtkPts(atk, cards)
    cards.each do |card|
      atk.push(card.atk_points)
    end
  end
end
