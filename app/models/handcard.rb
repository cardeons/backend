# frozen_string_literal: true

class Handcard < ApplicationRecord
  # belongs_to :ingamedeck

  has_many :ingamedecks, as: :cardable
  has_many :cards, through: :ingamedecks
  belongs_to :player
end
