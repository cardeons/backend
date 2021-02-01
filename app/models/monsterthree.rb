# frozen_string_literal: true

class Monsterthree < ApplicationRecord
  has_many :ingamedecks, as: :cardable
  belongs_to :player
end
