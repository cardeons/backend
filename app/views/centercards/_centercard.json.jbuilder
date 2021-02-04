# frozen_string_literal: true

json.extract! centercard, :id, :created_at, :updated_at
json.url centercard_url(centercard, format: :json)
