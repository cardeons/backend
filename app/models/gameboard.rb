class Gameboard < ApplicationRecord
    has_many :players
    has_many :ingame_cards
    # has_many :cards, through: :ingame_cards
end
