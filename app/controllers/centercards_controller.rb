# frozen_string_literal: true

class CentercardsController < ApplicationController
  before_action :set_centercard, only: %i[show edit update destroy]

  # GET /centercards
  # GET /centercards.json
  def index
    @centercards = Centercard.all
  end

  # GET /centercards/1
  # GET /centercards/1.json
  def show; end

  # GET /centercards/new
  def new
    @centercard = Centercard.new
  end

  # GET /centercards/1/edit
  def edit; end

  # POST /centercards
  # POST /centercards.json
  def create
    @centercard = Centercard.new(centercard_params)

    respond_to do |format|
      if @centercard.save
        format.html { redirect_to @centercard, notice: 'Centercard was successfully created.' }
        format.json { render :show, status: :created, location: @centercard }
      else
        format.html { render :new }
        format.json { render json: @centercard.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /centercards/1
  # PATCH/PUT /centercards/1.json
  def update
    respond_to do |format|
      if @centercard.update(centercard_params)
        format.html { redirect_to @centercard, notice: 'Centercard was successfully updated.' }
        format.json { render :show, status: :ok, location: @centercard }
      else
        format.html { render :edit }
        format.json { render json: @centercard.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /centercards/1
  # DELETE /centercards/1.json
  def destroy
    @centercard.destroy
    respond_to do |format|
      format.html { redirect_to centercards_url, notice: 'Centercard was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_centercard
    @centercard = Centercard.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def centercard_params
    params.fetch(:centercard, {})
  end
end
