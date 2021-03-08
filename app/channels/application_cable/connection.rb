# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def decoded_token(token)
      # header: { 'Authorization': 'Bearer <token>' }
      JWT.decode(token, 's3cr3t', true, algorithm: 'HS256')
    rescue JWT::DecodeError
      nil
    end

    def find_verified_user
      reject_unauthorized_connection unless request.headers[:HTTP_SEC_WEBSOCKET_PROTOCOL]
      token = request.headers[:HTTP_SEC_WEBSOCKET_PROTOCOL].split(' ').last
      decoded_token = decoded_token(token)

      # wrong type of JWT
      reject_unauthorized_connection unless decoded_token

      if (current_user = User.find(decoded_token[0]['user_id']))
        current_user
      else
        reject_unauthorized_connection
      end
    end
  end
end
