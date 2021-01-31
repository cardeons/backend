class Ingamedeck < ApplicationRecord
  belongs_to :card
  belongs_to :gameboard
  belongs_to :cardable, :polymorphic => true
end
