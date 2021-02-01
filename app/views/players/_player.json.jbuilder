# frozen_string_literal: true

json.extract! player, :id, :name, :avatar, :level, :attack, :is_cursed, :belongs_to, :created_at, :updated_at
json.url player_url(player, format: :json)
