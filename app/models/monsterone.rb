class Monsterone < ApplicationRecord
  has_many :ingamedecks, :as => :cardable
  belongs_to :player
end
