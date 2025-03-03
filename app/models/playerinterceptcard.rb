# frozen_string_literal: true

class Playerinterceptcard < ApplicationRecord
  belongs_to :gameboard
  validates_uniqueness_of :gameboard_id
  has_many :ingamedecks, as: :cardable
  has_many :cards, through: :ingamedecks

  def add_card_with_ingamedeck_id(unique_card_id)
    card = Ingamedeck.find_by('id=?', unique_card_id)

    card.update(cardable: self)
  end
end
