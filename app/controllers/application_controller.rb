# frozen_string_literal: true

class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  include ExceptionHandler

  def encode_token(payload)
    raise 'ENV[ENC_KEY] is not set' unless ENV['ENC_KEY']

    JWT.encode(payload, ENV['ENC_KEY'])
  end

  def auth_header
    # { Authorization: 'Bearer <token>' }
    request.headers['Authorization']
  end

  def decoded_token
    if auth_header
      token = auth_header.split[1]
      # header: { 'Authorization': 'Bearer <token>' }
      begin
        raise JWT::DecodeError 'ENV[ENC_KEY] is not set' unless ENV['ENC_KEY']

        JWT.decode(token, ENV['ENC_KEY'], true, algorithm: 'HS256')
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def logged_in_user
    if decoded_token
      user_id = decoded_token[0]['user_id']
      @current_user = User.find_by(id: user_id)
    end
  end

  def logged_in?
    !!logged_in_user
  end

  def authorized
    render json: { message: 'Please log in' }, status: :unauthorized unless logged_in?
    user_frontend = { id: @current_user.id, email: @current_user.email, name: @current_user.name }
    render json: { user: user_frontend } if logged_in?
  end
end
