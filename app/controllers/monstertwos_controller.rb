# frozen_string_literal: true

class MonstertwosController < ApplicationController
  before_action :set_monstertwo, only: %i[show edit update destroy]

  # GET /monstertwos
  # GET /monstertwos.json
  def index
    @monstertwos = Monstertwo.all
  end

  # GET /monstertwos/1
  # GET /monstertwos/1.json
  def show; end

  # GET /monstertwos/new
  def new
    @monstertwo = Monstertwo.new
  end

  # GET /monstertwos/1/edit
  def edit; end

  # POST /monstertwos
  # POST /monstertwos.json
  def create
    @monstertwo = Monstertwo.new(monstertwo_params)

    respond_to do |format|
      if @monstertwo.save
        format.html { redirect_to @monstertwo, notice: 'Monstertwo was successfully created.' }
        format.json { render :show, status: :created, location: @monstertwo }
      else
        format.html { render :new }
        format.json { render json: @monstertwo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /monstertwos/1
  # PATCH/PUT /monstertwos/1.json
  def update
    respond_to do |format|
      if @monstertwo.update(monstertwo_params)
        format.html { redirect_to @monstertwo, notice: 'Monstertwo was successfully updated.' }
        format.json { render :show, status: :ok, location: @monstertwo }
      else
        format.html { render :edit }
        format.json { render json: @monstertwo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /monstertwos/1
  # DELETE /monstertwos/1.json
  def destroy
    @monstertwo.destroy
    respond_to do |format|
      format.html { redirect_to monstertwos_url, notice: 'Monstertwo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_monstertwo
    @monstertwo = Monstertwo.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def monstertwo_params
    params.require(:monstertwo).permit(:ingamedeck_id, :player_id)
  end
end
