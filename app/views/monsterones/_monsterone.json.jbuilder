# frozen_string_literal: true

json.extract! monsterone, :id, :ingamedeck_id, :player_id, :created_at, :updated_at
json.url monsterone_url(monsterone, format: :json)
