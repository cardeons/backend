# frozen_string_literal: true

class GameboardsController < ApplicationController
  before_action :set_gameboard, only: %i[show edit update destroy]

  # GET /gameboards
  # GET /gameboards.json
  def index
    @gameboards = Gameboard.all
  end

  # GET /gameboards/1
  # GET /gameboards/1.json
  def show; end

  # GET /gameboards/new
  def new
    @gameboard = Gameboard.new
  end

  # GET /gameboards/1/edit
  def edit; end

  # POST /gameboards
  # POST /gameboards.json
  def create
    @gameboard = Gameboard.new(gameboard_params)

    respond_to do |format|
      if @gameboard.save
        format.html { redirect_to @gameboard, notice: 'Gameboard was successfully created.' }
        format.json { render :show, status: :created, location: @gameboard }
      else
        format.html { render :new }
        format.json { render json: @gameboard.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gameboards/1
  # PATCH/PUT /gameboards/1.json
  def update
    respond_to do |format|
      if @gameboard.update(gameboard_params)
        format.html { redirect_to @gameboard, notice: 'Gameboard was successfully updated.' }
        format.json { render :show, status: :ok, location: @gameboard }
      else
        format.html { render :edit }
        format.json { render json: @gameboard.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gameboards/1
  # DELETE /gameboards/1.json
  def destroy
    @gameboard.destroy
    respond_to do |format|
      format.html { redirect_to gameboards_url, notice: 'Gameboard was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_gameboard
    @gameboard = Gameboard.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def gameboard_params
    params.require(:gameboard).permit(:current_state, :player_atk, :monster_atk, :asked_help, :success, :can_flee, :shared_reward)
  end
end
