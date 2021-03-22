# frozen_string_literal: true

class Centercard < ApplicationRecord
  # has_many :ingamedecks, as: :cardable
  # has_many :cards, through: :ingamedecks
  has_one :ingamedeck, as: :cardable
  has_one :card, through: :ingamedeck

  belongs_to :gameboard
  validates_uniqueness_of :gameboard_id
  validates_presence_of :gameboard_id
end
