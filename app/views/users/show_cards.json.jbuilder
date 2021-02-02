# frozen_string_literal: true

# json.partial! 'users/card', user_card: @user_card
json.array! @user_cards, partial: 'users/card', as: :user_card
