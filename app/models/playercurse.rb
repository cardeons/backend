# frozen_string_literal: true

class Playercurse < ApplicationRecord
  has_many :ingamedecks, as: :cardable
  belongs_to :player
end
