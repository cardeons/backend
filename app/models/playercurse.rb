# frozen_string_literal: true

class Playercurse < ApplicationRecord
  has_many :ingamedecks, as: :cardable
  has_many :cards, through: :ingamedecks
  belongs_to :player
  validates_uniqueness_of :player_id
  validates_presence_of :player_id
end
