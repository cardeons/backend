# frozen_string_literal: true

class Inventory < ApplicationRecord
  has_many :ingamedecks, as: :cardable, dependent: :destroy
  has_many :cards, through: :ingamedecks
  belongs_to :player
end
