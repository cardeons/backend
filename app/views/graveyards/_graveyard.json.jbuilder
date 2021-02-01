# frozen_string_literal: true

json.extract! graveyard, :id, :gameboard_id, :ingamedeck_id, :created_at, :updated_at
json.url graveyard_url(graveyard, format: :json)
