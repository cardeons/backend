class Graveyard < ApplicationRecord
  belongs_to :gameboard
  has_many :ingamedeck
end
