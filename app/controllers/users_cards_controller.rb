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
    obj = {"card1" => 100}

    user_cards = User.find(id).cards
    i = 1
    user_cards.each do |user_card|
      type = user_card.type
      card_num = "card"+i.to_s
      type_num = "type"+i.to_s
      obj[card_num] = user_card
      obj[type_num] = type

      user_card["type"] = type
      user_card = user_card.to_json
      i = i+1
    end
    json_response(user_cards)

    # render :json => { :errors => user.errors.as_json }, :status => 420
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def json_response(object, status = :ok)
    render json: object, status: status
  end
end