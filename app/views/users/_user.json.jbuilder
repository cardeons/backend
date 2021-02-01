# frozen_string_literal: true

json.extract! user, :id, :name, :email
json.url user_url(user, format: :json)
