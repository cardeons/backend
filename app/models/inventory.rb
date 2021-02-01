# frozen_string_literal: true

class Inventory < ApplicationRecord
  has_many :ingamedecks, as: :cardable, dependent: :destroy
  belongs_to :player
end
