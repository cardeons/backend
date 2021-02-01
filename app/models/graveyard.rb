# frozen_string_literal: true

class Graveyard < ApplicationRecord
  belongs_to :gameboard
  has_many :ingamedeck
end
