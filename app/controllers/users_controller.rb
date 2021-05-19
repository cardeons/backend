# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[]

  # GET /users
  # GET /users.json
  def index
    # @users = User.all
  end

  def decoded_token(token)
    raise JWT::DecodeError 'ENV[ENC_KEY] is not set' unless ENV['ENC_KEY']

    JWT.decode(token, ENV['ENC_KEY'], true, algorithm: 'HS256')
  rescue JWT::DecodeError
    nil
  end

  def find_verified_user
    # token = request.headers['token']
    token = request.headers['Authorization'].split[1]

    decoded_token = decoded_token(token)

    # wrong type of JWT
    return false unless decoded_token

    return false unless User.find(decoded_token[0]['user_id'])

    true
  end

  def search
    @users = User.where('name like ?', "%#{params[:search]}%").first(5) if find_verified_user
  end

  # GET /users/1
  # GET /users/1.json
  # def show; end

  # GET /users/user/1
  # GET /users/1.json
  def show_cards
    @user_cards = User.find(params[:id]).cards
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit; end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.fetch(:user, {})
  end

  def user_card_params
    params.require(:user_card).permit(:card_id, :title, :type, :description, :image, :action, :draw_chance, :level, :element, :bad_things, :rewards_treasure, :good_against, :bad_against,
                                      :good_against_value, :bad_against_value, :atk_points, :item_category, :level_amount)
  end
end
