class SessionsController < ApplicationController
    def create
        #params kommen später vom Frontend
        registration_input = request.raw_post()
        registration_input = JSON.parse(registration_input)

        user = User.find_by(email: registration_input['email']).try(:authenticate, registration_input['password'])

        registration_input = request.raw_post()
        registration_input = JSON.parse(registration_input)

        # user.valid? später einbauen, wenn alles in der db steht!
        if user
            session[:user_id] = user.id
            token = encode_token({user_id: user.id})
            user_frontent = {"id": user.id,"email": user.email,"created_at": user.created_at,"updated_at": user.updated_at,"name": user.name}

            render json: {
                status: :created,
                logged_in: true,
                user: user_frontent,
                token: token
            }
        else
            # render json: {
            #     status: 401,
            #     error: 'Invalid username or password'
            # }
            render :json => { :errors => 'Invalid username or password' }, :status => 401
        end
    end

    # def logged_in
    #     if @current_user
    #         render json: {
    #             logged_in: true,
    #             user: @current_user,
    #             token: token
    #         }
    #     else
    #         render json: {
    #             logged_in: false
    #         }
    #     end
    # end

    # def logout
    #     reset_session
    #     render json: { status: 200, logged_out: true }
    # end
end