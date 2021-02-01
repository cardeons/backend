class Monsterone < ApplicationRecord
  has_many :ingamedecks, :as => :cardable, dependent: :destroy
  belongs_to :player
end
