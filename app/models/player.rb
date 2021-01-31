class Player < ApplicationRecord
    belongs_to :gameboard
    has_one :inventory
    has_one :handcard
    has_one :playerdeckcursecard
    has_one :playerdeckmonsterone
    has_one :playerdeckmonstertwo
    has_one :playerdeckmonsterthree
end
