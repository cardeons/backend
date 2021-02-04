# frozen_string_literal: true

class Graveyard < ApplicationRecord
  belongs_to :gameboard
  has_many :ingamedecks, as: :cardable
  has_many :cards, through: :ingamedecks
  validates_uniqueness_of :gameboard_id
  validates_presence_of :gameboard_id
end
