# frozen_string_literal: true

class Interceptcard < ApplicationRecord
  belongs_to :gameboard
  has_many :ingamedeck, dependent: :destroy
end
