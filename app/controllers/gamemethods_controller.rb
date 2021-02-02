# frozen_string_literal: true

class GamemethodsController < ApplicationController
  def draw_doorcard
    cursecards = Cursecard.all
    monstercards = Monstercard.all
    bosscards = Bosscard.all

    allcards = []

    cursecards.each do |card|
      x = card.draw_chance
      while x.positive?
        allcards.push card
        x -= 1
      end
    end

    monstercards.each do |card|
      x = card.draw_chance
      while x.positive?
        allcards.push card
        x -= 1
      end
    end

    bosscards.each do |card|
      x = card.draw_chance
      while x.positive?
        allcards.push card
        x -= 1
      end
    end

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

    cursecards.each do |card|
      x = card.draw_chance
      while x.positive?
        allcards.push card
        x -= 1
      end
    end

    monstercards.each do |card|
      x = card.draw_chance
      while x.positive?
        allcards.push card
        x -= 1
      end
    end

    buffcards.each do |card|
      x = card.draw_chance
      while x.positive?
        allcards.push card
        x -= 1
      end
    end

    itemcards.each do |card|
      x = card.draw_chance
      while x.positive?
        allcards.push card
        x -= 1
      end
    end

    levelcards.each do |card|
      x = card.draw_chance
      while x.positive?
        allcards.push card
        x -= 1
      end
    end

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

    cursecards.each do |card|
      x = card.draw_chance
      while x.positive?
        allcards.push card.id
        x -= 1
      end
    end

    monstercards.each do |card|
      x = card.draw_chance
      while x.positive?
        allcards.push card.id
        x -= 1
      end
    end

    buffcards.each do |card|
      x = card.draw_chance
      while x.positive?
        allcards.push card.id
        x -= 1
      end
    end

    itemcards.each do |card|
      x = card.draw_chance
      while x.positive?
        allcards.push card.id
        x -= 1
      end
    end

    levelcards.each do |card|
      x = card.draw_chance
      while x.positive?
        allcards.push card.id
        x -= 1
      end
    end

    handcard = Player.find(params[:id]).handcard

    Ingamedeck.where(cardable_type: 'Handcard', cardable_id: handcard.id).delete_all

    Ingamedeck.create(gameboard_id: params[:gameboard_id], card_id: allcards[rand(allcards.length)], cardable_id: handcard.id, cardable_type: 'Handcard')
    Ingamedeck.create(gameboard_id: params[:gameboard_id], card_id: allcards[rand(allcards.length)], cardable_id: handcard.id, cardable_type: 'Handcard')
    Ingamedeck.create(gameboard_id: params[:gameboard_id], card_id: allcards[rand(allcards.length)], cardable_id: handcard.id, cardable_type: 'Handcard')
    Ingamedeck.create(gameboard_id: params[:gameboard_id], card_id: allcards[rand(allcards.length)], cardable_id: handcard.id, cardable_type: 'Handcard')
    Ingamedeck.create(gameboard_id: params[:gameboard_id], card_id: allcards[rand(allcards.length)], cardable_id: handcard.id, cardable_type: 'Handcard')

    render json: { card: handcard.cards }, status: 200
  end
end
