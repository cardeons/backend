# frozen_string_literal: true

class Inventory < ApplicationRecord
  has_many :ingamedecks, as: :cardable
  has_many :cards, through: :ingamedecks
  belongs_to :player
end
