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
      x = card[0]
      while x.positive?
        arr.push card[1]
        x -= 1
      end
    end
  end

  def self.draw_handcards(player_id, gameboard, card_amount = 5)

    ## only select draw_chance & id, not whole model
    all_cards = Card.all.where.not('type=?', 'Bosscard').pluck(:draw_chance, :id)
    # pp all_cards
    # cursecards = Cursecard.all.pluck(:draw_chance, :id)
    # monstercards = Monstercard.all.pluck(:draw_chance, :id)
    # buffcards = Buffcard.all.pluck(:draw_chance, :id)
    # itemcards = Itemcard.all.pluck(:draw_chance, :id)
    # levelcards = Levelcard.all.pluck(:draw_chance, :id)

    allcards = []
    # addCardsToArray(allcards, cursecards)
    # addCardsToArray(allcards, monstercards)
    # addCardsToArray(allcards, buffcards)
    # addCardsToArray(allcards, itemcards)
    addCardsToArray(allcards, all_cards)

    # pp allcards
    player = Player.find(player_id)
    handcard = player.handcard

    # Ingamedeck.create!(gameboard: gameboard, card_id: Itemcard.first.id, cardable: handcard)

    # Ingamedeck.where(cardable_type: 'Handcard', cardable_id: handcard.id).delete_all

    # TODO: draw lvl one card if no Inventory cards
    # TODO die x variable ändern je nachdem wie viele Karten Spieler mit ins Game nimmt :)
    # TODO bei keiner mitgenommenen Karte random lvl one als monsterone, ansonsten Handkarten
    x = card_amount
    while x.positive?
      Ingamedeck.create!(gameboard: gameboard, card_id: allcards[rand(allcards.size)], cardable: handcard)
      x -= 1
    end
  end
end
