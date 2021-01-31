class MonsterthreesController < ApplicationController
  before_action :set_monsterthree, only: [:show, :edit, :update, :destroy]

  # GET /monsterthrees
  # GET /monsterthrees.json
  def index
    @monsterthrees = Monsterthree.all
  end

  # GET /monsterthrees/1
  # GET /monsterthrees/1.json
  def show
  end

  # GET /monsterthrees/new
  def new
    @monsterthree = Monsterthree.new
  end

  # GET /monsterthrees/1/edit
  def edit
  end

  # POST /monsterthrees
  # POST /monsterthrees.json
  def create
    @monsterthree = Monsterthree.new(monsterthree_params)

    respond_to do |format|
      if @monsterthree.save
        format.html { redirect_to @monsterthree, notice: 'Monsterthree was successfully created.' }
        format.json { render :show, status: :created, location: @monsterthree }
      else
        format.html { render :new }
        format.json { render json: @monsterthree.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /monsterthrees/1
  # PATCH/PUT /monsterthrees/1.json
  def update
    respond_to do |format|
      if @monsterthree.update(monsterthree_params)
        format.html { redirect_to @monsterthree, notice: 'Monsterthree was successfully updated.' }
        format.json { render :show, status: :ok, location: @monsterthree }
      else
        format.html { render :edit }
        format.json { render json: @monsterthree.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /monsterthrees/1
  # DELETE /monsterthrees/1.json
  def destroy
    @monsterthree.destroy
    respond_to do |format|
      format.html { redirect_to monsterthrees_url, notice: 'Monsterthree was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_monsterthree
      @monsterthree = Monsterthree.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def monsterthree_params
      params.require(:monsterthree).permit(:ingamedeck_id, :player_id)
    end
end
