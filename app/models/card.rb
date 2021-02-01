class Card < ApplicationRecord
    # has_many :ingame_cards
    # has_many :inventories, through: :ingame_cards
    # has_many :ingame_cards
    # has_many :gameboards :ingame_cards
    has_and_belongs_to_many :users
end
