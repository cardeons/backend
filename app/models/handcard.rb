# frozen_string_literal: true

class Handcard < ApplicationRecord
  # belongs_to :ingamedeck
  has_many :ingamedecks, as: :cardable, dependent: :destroy
  belongs_to :player
end
