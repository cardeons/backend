# frozen_string_literal: true

json.extract! monsterthree, :id, :ingamedeck_id, :player_id, :created_at, :updated_at
json.url monsterthree_url(monsterthree, format: :json)
