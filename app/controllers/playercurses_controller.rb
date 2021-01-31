class PlayercursesController < ApplicationController
  before_action :set_playercurse, only: [:show, :edit, :update, :destroy]

  # GET /playercurses
  # GET /playercurses.json
  def index
    @playercurses = Playercurse.all
  end

  # GET /playercurses/1
  # GET /playercurses/1.json
  def show
  end

  # GET /playercurses/new
  def new
    @playercurse = Playercurse.new
  end

  # GET /playercurses/1/edit
  def edit
  end

  # POST /playercurses
  # POST /playercurses.json
  def create
    @playercurse = Playercurse.new(playercurse_params)

    respond_to do |format|
      if @playercurse.save
        format.html { redirect_to @playercurse, notice: 'Playercurse was successfully created.' }
        format.json { render :show, status: :created, location: @playercurse }
      else
        format.html { render :new }
        format.json { render json: @playercurse.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /playercurses/1
  # PATCH/PUT /playercurses/1.json
  def update
    respond_to do |format|
      if @playercurse.update(playercurse_params)
        format.html { redirect_to @playercurse, notice: 'Playercurse was successfully updated.' }
        format.json { render :show, status: :ok, location: @playercurse }
      else
        format.html { render :edit }
        format.json { render json: @playercurse.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /playercurses/1
  # DELETE /playercurses/1.json
  def destroy
    @playercurse.destroy
    respond_to do |format|
      format.html { redirect_to playercurses_url, notice: 'Playercurse was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_playercurse
      @playercurse = Playercurse.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def playercurse_params
      params.require(:playercurse).permit(:ingamedeck_id, :player_id)
    end
end
