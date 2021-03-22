# frozen_string_literal: true

class Centercard < ApplicationRecord
  has_many :ingamedecks, as: :cardable
  has_many :cards, through: :ingamedecks

  belongs_to :gameboard
  validates_uniqueness_of :gameboard_id
  validates_presence_of :gameboard_id
end
