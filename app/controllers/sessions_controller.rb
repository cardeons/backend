# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    registration_input = request.raw_post
    registration_input = JSON.parse(registration_input)

    user = User.find_by(email: registration_input['email']).try(:authenticate, registration_input['password'])

    if user
      session[:user_id] = user.id
      token = encode_token({ user_id: user.id })
      user_frontent = { id: user.id, email: user.email, created_at: user.created_at, updated_at: user.updated_at, name: user.name }

      render json: {
        status: :created,
        logged_in: true,
        user: user_frontent,
        token: token
      }
    else
      render json: { errors: 'Invalid username or password' }, status: 401
    end
  end
end
