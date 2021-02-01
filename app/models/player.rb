class Player < ApplicationRecord
    belongs_to :gameboard
    has_one :inventory, dependent: :destroy
    has_one :handcard, dependent: :destroy
    has_one :cursecard, dependent: :destroy
    has_one :monsterone, dependent: :destroy
    has_one :monstertwo, dependent: :destroy
    has_one :monsterthree, dependent: :destroy
    has_one :playercurse, dependent: :destroy
end
