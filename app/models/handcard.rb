# frozen_string_literal: true

class Handcard < ApplicationRecord
  # belongs_to :ingamedeck

  has_many :ingamedecks, as: :cardable
  has_many :cards, through: :ingamedecks
  belongs_to :player 
  validates_uniqueness_of :player_id
  validates_presence_of :player_id

  
  def self.addCardsToArray(arr, cards)
    cards.each do |card|
      x = card.draw_chance
      while x.positive?
        arr.push card.id
        x -= 1
      end
    end
  end

  def self.draw_handcards(player_id, gameboard)
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
    player = Player.find(player_id)
    handcard = player.handcard
    # puts "**********************+"
    # pp handcard.cards
  
    # Ingamedeck.where(cardable_type: 'Handcard', cardable_id: handcard.id).delete_all
  
    # TODO: draw lvl one card if no Inventory cards
    # TODO die x variable ändern je nachdem wie viele Karten Spieler mit ins Game nimmt :)
    # TODO bei keiner mitgenommenen Karte random lvl one als monsterone, ansonsten Handkarten
    x = 5
    while x.positive?
      Ingamedeck.create!(gameboard: gameboard, card_id: allcards[rand(allcards.length)], cardable: handcard)
      x -= 1
    end
  end
  
end

