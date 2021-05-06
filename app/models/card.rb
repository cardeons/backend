# frozen_string_literal: true

class Card < ApplicationRecord
  # has_many :ingame_cards
  # has_many :inventories, through: :ingame_cards
  # has_many :ingame_cards
  # has_many :gameboards :ingame_cards
  has_and_belongs_to_many :users
  enum good_against: %i[fire water air earth], _suffix: true
  enum bad_against: %i[fire water air earth], _suffix: true
  enum element: %i[fire water air earth]
  enum synergy_type: %i[bull buffalo bear unicorn catfish hotdog boar pizza], _suffix: true
  enum animal: %i[bull buffalo bear unicorn catfish hotdog boar pizza]

  # has_many :ingamedecks
  # has_many :monsterthrees, through: :ingamedecks, source: :cardable, source_type: 'Monsterthree'

  def calculate_self_element_modifiers(other_card)
    modifier = 0

    return modifier unless other_card.element

    # if good_against is not nil and the same element
    modifier += good_against_value if good_against && good_against == other_card.element

    # if bad_against is not nil and the same element
    modifier -= bad_against_value if bad_against && bad_against == other_card.element

    modifier
  end
end
