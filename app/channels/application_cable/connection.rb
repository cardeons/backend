# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      puts "-----------------------------"
      puts current_user.email
      puts "found current User"
    end

    private

    def auth_header
      # { Authorization: 'Bearer <token>' }
      request.headers['Authorization']
    end

  
    def decoded_token
      if auth_header
        token = auth_header.split[1]
        # header: { 'Authorization': 'Bearer <token>' }
        begin
          JWT.decode(token, 's3cr3t', true, algorithm: 'HS256')
        rescue JWT::DecodeError
          nil
        end
      end
    end
  
    def logged_in_user
      if decoded_token
        user_id = decoded_token[0]['user_id']
        User.find_by(id: user_id)
      end
    end
  

    def find_verified_user
      if logged_in_user
        verified_user
      else
        reject_unauthorized_connection
      end
    end
  end
end
