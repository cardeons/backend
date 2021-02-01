# frozen_string_literal: true

json.array! @cards, partial: 'cards/card', as: :card
