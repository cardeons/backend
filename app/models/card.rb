# frozen_string_literal: true

class Card < ApplicationRecord
  # has_many :ingame_cards
  # has_many :inventories, through: :ingame_cards
  # has_many :ingame_cards
  # has_many :gameboards :ingame_cards
  has_and_belongs_to_many :users
  has_many :ingamedecks
  has_many :monsterthrees, through: :ingamedecks, source: :cardable, source_type: 'Monsterthree'
end
