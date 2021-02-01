# frozen_string_literal: true

json.extract! playercurse, :id, :ingamedeck_id, :player_id, :created_at, :updated_at
json.url playercurse_url(playercurse, format: :json)
