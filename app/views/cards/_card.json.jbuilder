# frozen_string_literal: true

json.extract! card, :id, :title, :type, :description, :image, :action, :draw_chance, :level, :element, :bad_things, :rewards_treasure, :good_against, :bad_against, :good_against_value,
              :bad_against_value, :atk_points, :item_category, :level_amount, :synergy_type, :synergy_value, :animal, :created_at, :updated_at
json.url card_url(card, format: :json)
