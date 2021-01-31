class SessionsController < ApplicationController
    # include CurrentUserConcern

    def create
        #params kommen später vom Frontend
        user = User.create(email: 'daniela-dottolo@gmx.at', password: 'hahasosecret123')


        # user.valid? später einbauen, wenn alles in der db steht!
        if user
            session[:user_id] = user.id
            token = encode_token({user_id: user.id})

            render json: {
                status: :created,
                logged_in: true,
                user: user,
                token: token
            }
        else
            render json: {
                status: 401,
                error: 'Invalid username or password'
            }
        end
    end

    def logged_in
        if @current_user
            render json: {
                logged_in: true,
                user: @current_user,
                token: token
            }
        else
            render json: {
                logged_in: false
            }
        end
    end

    def logout
        reset_session
        render json: { status: 200, logged_out: true }
    end
end