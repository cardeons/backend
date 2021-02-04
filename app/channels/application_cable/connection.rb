# frozen_string_literal: true

require 'pp'

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      puts '-----------------------------'
      puts 'found current User'
      puts current_user.email
    end

    private

    def decoded_token(token)
      # header: { 'Authorization': 'Bearer <token>' }
      JWT.decode(token, 's3cr3t', true, algorithm: 'HS256')
    rescue JWT::DecodeError
      nil
    end

    def find_verified_user
      token = request.headers[:HTTP_SEC_WEBSOCKET_PROTOCOL].split(' ').last
      decoded_token = decoded_token(token)

      puts '-----------------------'
      puts decoded_token
      puts decoded_token[0]['user_id']

      if (current_user = User.find(decoded_token[0]['user_id']))
        pp current_user
        current_user
      else
        reject_unauthorized_connection
      end
    end

    # def auth_header
    #   { Authorization: 'Bearer <token>' }

    #   request.headers['Authorization']
    # end

    # def logged_in_user
    #   if decoded_token
    #     user_id = decoded_token[0]['user_id']
    #     User.find_by(id: user_id)
    #   end
    # end

    # def find_verified_user
    #   if logged_in_user

    #     puts '#######################################################'
    #     puts 'user used valid token'
    #     puts '#######################################################################'
    #     verified_user

    #   else
    #     # reject_unauthorized_connection
    #     puts '-------------------------------------------'
    #     puts 'could not find user creates a new one now'
    #     # TODO: reject conecttion
    #     verified_user = User.find(rand(1..User.all.count))
    #   end
  end
end
