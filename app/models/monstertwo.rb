# frozen_string_literal: true

class Monstertwo < ApplicationRecord
  has_many :ingamedecks, as: :cardable
  belongs_to :player
end
