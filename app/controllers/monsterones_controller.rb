class MonsteronesController < ApplicationController
  before_action :set_monsterone, only: [:show, :edit, :update, :destroy]

  # GET /monsterones
  # GET /monsterones.json
  def index
    @monsterones = Monsterone.all
  end

  # GET /monsterones/1
  # GET /monsterones/1.json
  def show
  end

  # GET /monsterones/new
  def new
    @monsterone = Monsterone.new
  end

  # GET /monsterones/1/edit
  def edit
  end

  # POST /monsterones
  # POST /monsterones.json
  def create
    @monsterone = Monsterone.new(monsterone_params)

    respond_to do |format|
      if @monsterone.save
        format.html { redirect_to @monsterone, notice: 'Monsterone was successfully created.' }
        format.json { render :show, status: :created, location: @monsterone }
      else
        format.html { render :new }
        format.json { render json: @monsterone.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /monsterones/1
  # PATCH/PUT /monsterones/1.json
  def update
    respond_to do |format|
      if @monsterone.update(monsterone_params)
        format.html { redirect_to @monsterone, notice: 'Monsterone was successfully updated.' }
        format.json { render :show, status: :ok, location: @monsterone }
      else
        format.html { render :edit }
        format.json { render json: @monsterone.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /monsterones/1
  # DELETE /monsterones/1.json
  def destroy
    @monsterone.destroy
    respond_to do |format|
      format.html { redirect_to monsterones_url, notice: 'Monsterone was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_monsterone
      @monsterone = Monsterone.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def monsterone_params
      params.require(:monsterone).permit(:ingamedeck_id, :player_id)
    end
end
