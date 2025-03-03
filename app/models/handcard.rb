# frozen_string_literal: true

class Handcard < ApplicationRecord
  # belongs_to :ingamedeck

  has_many :ingamedecks, as: :cardable
  has_many :cards, through: :ingamedecks
  belongs_to :player
  validates_uniqueness_of :player_id
  validates_presence_of :player_id

  def self.add_cards_to_array(arr, cards)
    cards.each do |card|
      x = card.draw_chance
      while x.positive?
        arr.push card.id
        x -= 1
      end
    end
  end

  def self.draw_handcards(player_id, gameboard, card_amount = 5)
    cursecards = Cursecard.all
    monstercards = Monstercard.all
    buffcards = Buffcard.all
    itemcards = Itemcard.all
    levelcards = Levelcard.all

    allcards = []
    add_cards_to_array(allcards, cursecards)
    add_cards_to_array(allcards, monstercards)
    add_cards_to_array(allcards, buffcards)
    add_cards_to_array(allcards, itemcards)
    add_cards_to_array(allcards, levelcards)

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
    PlayerChannel.broadcast_to(player.user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(player.handcard.ingamedecks.reload) } })
  end

  def self.draw_one_monster(player_id, gameboard)
    monstercards = Monstercard.all

    allcards = []
    add_cards_to_array(allcards, monstercards)

    player = Player.find(player_id)
    handcard = player.handcard

    x = 1
    while x.positive?
      Ingamedeck.create!(gameboard: gameboard, card_id: allcards[rand(allcards.size)], cardable: handcard)
      x -= 1
    end
    PlayerChannel.broadcast_to(player.user, { type: 'HANDCARD_UPDATE', params: { handcards: Gameboard.render_cards_array(player.handcard.ingamedecks.reload) } })
  end
end
