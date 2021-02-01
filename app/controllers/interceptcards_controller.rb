class InterceptcardsController < ApplicationController
  before_action :set_interceptcard, only: [:show, :edit, :update, :destroy]

  # GET /interceptcards
  # GET /interceptcards.json
  def index
    @interceptcards = Interceptcard.all
  end

  # GET /interceptcards/1
  # GET /interceptcards/1.json
  def show
  end

  # GET /interceptcards/new
  def new
    @interceptcard = Interceptcard.new
  end

  # GET /interceptcards/1/edit
  def edit
  end

  # POST /interceptcards
  # POST /interceptcards.json
  def create
    @interceptcard = Interceptcard.new(interceptcard_params)

    respond_to do |format|
      if @interceptcard.save
        format.html { redirect_to @interceptcard, notice: 'Interceptcard was successfully created.' }
        format.json { render :show, status: :created, location: @interceptcard }
      else
        format.html { render :new }
        format.json { render json: @interceptcard.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /interceptcards/1
  # PATCH/PUT /interceptcards/1.json
  def update
    respond_to do |format|
      if @interceptcard.update(interceptcard_params)
        format.html { redirect_to @interceptcard, notice: 'Interceptcard was successfully updated.' }
        format.json { render :show, status: :ok, location: @interceptcard }
      else
        format.html { render :edit }
        format.json { render json: @interceptcard.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /interceptcards/1
  # DELETE /interceptcards/1.json
  def destroy
    @interceptcard.destroy
    respond_to do |format|
      format.html { redirect_to interceptcards_url, notice: 'Interceptcard was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_interceptcard
      @interceptcard = Interceptcard.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def interceptcard_params
      params.require(:interceptcard).permit(:gameboard_id, :ingamedeck_id)
    end
end
