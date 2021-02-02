# frozen_string_literal: true

class Monsterone < ApplicationRecord
  has_many :ingamedecks, as: :cardable, dependent: :destroy
  has_many :cards, through: :ingamedecks
  belongs_to :player
end
