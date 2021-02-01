# frozen_string_literal: true

json.extract! inventory, :id, :ingamedeck_id, :player_id, :created_at, :updated_at
json.url inventory_url(inventory, format: :json)
