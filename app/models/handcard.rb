class Handcard < ApplicationRecord
  # belongs_to :ingamedeck
  has_many :ingamedecks, :as => :cardable
  belongs_to :player
end
