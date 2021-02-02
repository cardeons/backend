# frozen_string_literal: true

class GamemethodsController < ApplicationController
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
