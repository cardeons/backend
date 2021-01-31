class Monsterthree < ApplicationRecord
  has_many :ingamedecks, :as => :cardable
  belongs_to :player

  validates :player_id, presence: true
end
