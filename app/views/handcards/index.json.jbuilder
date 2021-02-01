# frozen_string_literal: true

json.array! @handcards, partial: 'handcards/handcard', as: :handcard
