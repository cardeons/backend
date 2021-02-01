# frozen_string_literal: true

class HandcardsController < ApplicationController
  before_action :set_handcard, only: %i[show edit update destroy]

  # GET /handcards
  # GET /handcards.json
  def index
    @handcards = Handcard.all
  end

  # GET /handcards/1
  # GET /handcards/1.json
  def show; end

  # GET /handcards/new
  def new
    @handcard = Handcard.new
  end

  # GET /handcards/1/edit
  def edit; end

  # POST /handcards
  # POST /handcards.json
  def create
    @handcard = Handcard.new(handcard_params)

    respond_to do |format|
      if @handcard.save
        format.html { redirect_to @handcard, notice: 'Handcard was successfully created.' }
        format.json { render :show, status: :created, location: @handcard }
      else
        format.html { render :new }
        format.json { render json: @handcard.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /handcards/1
  # PATCH/PUT /handcards/1.json
  def update
    respond_to do |format|
      if @handcard.update(handcard_params)
        format.html { redirect_to @handcard, notice: 'Handcard was successfully updated.' }
        format.json { render :show, status: :ok, location: @handcard }
      else
        format.html { render :edit }
        format.json { render json: @handcard.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /handcards/1
  # DELETE /handcards/1.json
  def destroy
    @handcard.destroy
    respond_to do |format|
      format.html { redirect_to handcards_url, notice: 'Handcard was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_handcard
    @handcard = Handcard.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def handcard_params
    params.require(:handcard).permit(:ingamedeck_id, :player_id)
  end
end
