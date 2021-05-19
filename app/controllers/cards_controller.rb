# frozen_string_literal: true

class CardsController < ApplicationController
  before_action :set_card, only: %i[show]

  # GET /cards
  # GET /cards.json
  def index
    @cards = Card.all
  end

  # GET /cards/1
  # GET /cards/1.json
  def show; end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_card
    @card = Card.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def card_params
    params.require(:card).permit(:card_id, :title, :type, :description, :image, :action, :draw_chance, :level, :element, :bad_things, :rewards_treasure, :good_against, :bad_against,
                                 :good_against_value, :bad_against_value, :atk_points, :item_category, :level_amount, :synergy_type, :synergy_value, :animal)
  end
end
