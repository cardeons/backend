# frozen_string_literal: true

class GamemethodsController < ApplicationController
  # def draw_random_lvl_one
  #   monstercards = Monstercard.all.where('level=?', 1).pluck(:id).sample

  #   render json: { card: Monstercard.find(monstercards) }, status: 200
  # end

  # cursecards = Cursecard.all
  # monstercards = Monstercard.all
  # bosscards = Bosscard.all
  # buffcards = Buffcard.all
  # itemcards = Itemcard.all
  # levelcards = Levelcard.all

  # all_treasure_cards = []
  # addCardsToArray(all_treasure_cards, cursecards)
  # addCardsToArray(all_treasure_cards, monstercards)
  # addCardsToArray(all_treasure_cards, buffcards)
  # addCardsToArray(all_treasure_cards, itemcards)
  # addCardsToArray(all_treasure_cards, levelcards)

  # all_door_cards = []
  # addCardsToArray(all_door_cards, cursecards)
  # addCardsToArray(all_door_cards, monstercards)
  # addCardsToArray(all_door_cards, bosscards)

  # cursecards = Cursecard.all
  # monstercards = Monstercard.all
  # buffcards = Buffcard.all
  # itemcards = Itemcard.all
  # levelcards = Levelcard.all

  # all_hand_cards = []
  # addCardsToArray(all_hand_cards, cursecards)
  # addCardsToArray(all_hand_cards, monstercards)
  # addCardsToArray(all_hand_cards, buffcards)
  # addCardsToArray(all_hand_cards, itemcards)
  # addCardsToArray(all_hand_cards, levelcards)

  # def draw_doorcard
  #   randomcard = all_door_cards[rand(all_door_cards.length)]

  #   render json: { card: randomcard }, status: 200
  # end

  # def draw_treasurecard
  #   randomcard = all_treasure_cards[rand(all_treasure_cards.length)]

  #   render json: { card: randomcard }, status: 200
  # end

  # def draw_handcards
  #   handcard = Player.find(params[:id]).handcard

  #   # Ingamedeck.where(cardable_type: 'Handcard', cardable_id: handcard.id).delete_all

  #   # TODO: draw lvl one card if no Inventory cards
  #   # TODO die x variable ändern je nachdem wie viele Karten Spieler mit ins Game nimmt :)
  #   # TODO bei keiner mitgenommenen Karte random lvl one als monsterone, ansonsten Handkarten
  #   x = 5
  #   while x.positive?
  #     Ingamedeck.create(gameboard_id: params[:gameboard_id], card_id: all_hand_cards[rand(all_hand_cards.length)], cardable_id: handcard.id, cardable_type: 'Handcard')
  #     x -= 1
  #   end

  #   render json: { card: handcard.cards }, status: 200
  # end

  # def addCardsToArray(arr, cards)
  #   cards.each do |card|
  #     x = card.draw_chance
  #     while x.positive?
  #       arr.push card.id
  #       x -= 1
  #     end
  #   end
  # end

  # def canFlee?
  #   render json: rand(6) > 3
  # end

  # def attack(monsterid = params[:monsterid], playerid = params[:playerid])
  #   player = Player.find(playerid)
  #   monstercards1 = player.monsterone.cards.sum(:atk_points) if player.monsterone
  #   monstercards2 = player.monstertwo.cards.sum(:atk_points) if player.monstertwo
  #   monstercards3 = player.monsterthree.cards.sum(:atk_points) if player.monsterthree

  #   # temparr = []

  #   # addAtkPts(temparr, monstercards1)
  #   # addAtkPts(temparr, monstercards2)
  #   # addAtkPts(temparr, monstercards3)

  #   # playeratkpts = 0

  #   # temparr.each do |item|
  #   #   playeratkpts += item
  #   # end

  #   monsteratkpts = Monstercard.find(monsterid).atk_points

  #   playerwin = (monstercards1 + monstercards2 + monstercards3 + player.level) > monsteratkpts

  #   if playerwin
  #   # broadcast: start interceptionface
  #   else
  #     # broadcast: flee or use cards!
  #   end

  #   render json:
  #   {
  #     player_id: playerid,
  #     monster_id: monsterid,

  #     # playermonster: monstercards1,
  #     # playermonster2: monstercards2,
  #     # playermonster3: monstercards3,

  #     totalplayeratk: playeratkpts,
  #     monsteratk: monsteratkpts,
  #     playerwin: playerwin
  #   }
  # end

  # def addAtkPts(atk, cards)
  #   cards.each do |card|
  #     atk.push(card.atk_points)
  #   end
  # end
end
