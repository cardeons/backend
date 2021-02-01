class RegistrationsController < ApplicationController
    def create
        registration_input = request.raw_post()
        registration_input = JSON.parse(registration_input)
        user = User.new(
            email: registration_input['email'],
            name: registration_input['name'],
            password: registration_input['password'],
            password_confirmation: registration_input['password_confirmation']
        )
        user_frontent = {"id": user.id,"email": user.email,"created_at": user.created_at,"updated_at": user.updated_at,"name": user.name}

        if user.save
            session[:user_id] = user.id
            render json: {
                status: :created,
                user: user_frontent
            }
        else
            render :json => { :errors => user.errors.as_json }, :status => 420
        end
    end
end