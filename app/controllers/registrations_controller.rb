class RegistrationsController < ApplicationController
    def create
        registration_input = request.raw_post()
        registration_input = JSON.parse(registration_input)
        user = User.create!(
            email: registration_input['email'],
            name: registration_input['name'],
            password: registration_input['password'],
            password_confirmation: registration_input['password_confirmation']
        )

        if user
            session[:user_id] = user.id
            render json: {
                status: :created,
                user: user
            }
        else
            render json: { status: 400 }
        end
    end
end