# frozen_string_literal: true

# json.extract! user, :id, :name, :email
json.extract! user, :id, :name
json.url user_url(user, format: :json)
