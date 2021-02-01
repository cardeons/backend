# frozen_string_literal: true

class IngamedecksController < ApplicationController
  before_action :set_ingamedeck, only: %i[show edit update destroy]

  # GET /ingamedecks
  # GET /ingamedecks.json
  def index
    @ingamedecks = Ingamedeck.all
  end

  # GET /ingamedecks/1
  # GET /ingamedecks/1.json
  def show; end

  # GET /ingamedecks/new
  def new
    @ingamedeck = Ingamedeck.new
  end

  # GET /ingamedecks/1/edit
  def edit; end

  # POST /ingamedecks
  # POST /ingamedecks.json
  def create
    @ingamedeck = Ingamedeck.new(ingamedeck_params)

    respond_to do |format|
      if @ingamedeck.save
        format.html { redirect_to @ingamedeck, notice: 'Ingamedeck was successfully created.' }
        format.json { render :show, status: :created, location: @ingamedeck }
      else
        format.html { render :new }
        format.json { render json: @ingamedeck.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ingamedecks/1
  # PATCH/PUT /ingamedecks/1.json
  def update
    respond_to do |format|
      if @ingamedeck.update(ingamedeck_params)
        format.html { redirect_to @ingamedeck, notice: 'Ingamedeck was successfully updated.' }
        format.json { render :show, status: :ok, location: @ingamedeck }
      else
        format.html { render :edit }
        format.json { render json: @ingamedeck.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ingamedecks/1
  # DELETE /ingamedecks/1.json
  def destroy
    @ingamedeck.destroy
    respond_to do |format|
      format.html { redirect_to ingamedecks_url, notice: 'Ingamedeck was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_ingamedeck
    @ingamedeck = Ingamedeck.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def ingamedeck_params
    params.require(:ingamedeck).permit(:card_id, :gameboard_id)
  end
end
