# frozen_string_literal: true

class EquipController < ApplicationController
    # before_action :set_card, only: %i[show edit update destroy]
  
    # GET /cards
    # GET /cards.json
    def find_card

    end

    def index
        player = Player.find(params[:player_id])
        gameboard_id = params[:gameboard_id]
        position = params[:type]
        card_id = params[:deck_id]

        puts position + "*****" + card_id
        
        #TODO frontend schickt player, von wo die karte kommt und card_id
        @deck_card = Ingamedeck.find_by("id=?", card_id)
        @card = Card.find_by("id=?", @deck_card.card_id)

    
        #TODO frontend schickt auch, auf welches Monster die Karte kommt (Monsterone, Monstertwo, Monsterthree). Zuzreit statisch monsterone
        #TODO validieren
        @monster_to_equip = player.monsterone

        # if player.monsterone.cards.count == 5
        #     puts "**************"
        #     error_message = "sorry you can't put any more items on this monster"
        # elsif @monster_to_equip.cards.where("item_category=?", @card.item_category).count > 0
        #     puts "**************"
        #     error_message = "nono not allowed, you already have " + @card.item_category
        # else
            puts "************** created Card *************"
            cardable = player.monsterone.id
            Ingamedeck.new(gameboard_id: params[:gameboard_id], card_id: @card.id, cardable_id: cardable, cardable_type: 'Monsterone').save!
            puts "************** created Card *************"
            error_message = "no problem"
        # end

       

        render json: { card_to_add: @card, result: error_message, player_cards: Player.find(params[:player_id]).monsterone.cards }, status: 200

    end
end

  