# frozen_string_literal: true

class UsersCardsController < ApplicationController
  # before_action :set_card, only: [:show, :edit, :update, :destroy]

  # GET /cards
  # GET /cards.json
  def index; end

  # GET /cards/1
  # GET /cards/1.json
  def show
    xd = request.raw_post
    card_input = JSON.parse(xd)
    id = card_input['id']

    user_cards = User.find(id).cards

    json_response(user_cards)

    # render :json => { :errors => user.errors.as_json }, :status => 420
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def json_response(object, status = :ok)
    render json: object, status: status
  end
end
