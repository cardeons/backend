# frozen_string_literal: true

json.extract! user_card, :id, :title, :type, :description, :image, :action, :draw_chance, :level, :element, :bad_things, :rewards_treasure, :good_against, :bad_against, :good_against_value,
              :bad_against_value, :element_modifier, :atk_points, :item_category, :has_combination, :level_amount, :created_at, :updated_at
json.url card_url(user_card, format: :json)
