# frozen_string_literal: true

json.extract! handcard, :id, :ingamedeck_id, :player_id, :created_at, :updated_at
json.url handcard_url(handcard, format: :json)
