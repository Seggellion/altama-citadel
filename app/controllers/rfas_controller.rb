class RfasController < ApplicationController
  before_action :set_rfa, only: %i[ show edit update destroy ]

  # GET /rfas or /rfas.json
  def index
    @rfas = Rfa.all
  end

  # GET /rfas/1 or /rfas/1.json
  def show
  end

  # GET /rfas/new
  def new
    @rfa = Rfa.new
  end

  # GET /rfas/1/edit
  def edit
  end

  # POST /rfas or /rfas.json
  def create
    @rfa = Rfa.new(rfa_params)
binding.break
    respond_to do |format|
      if @rfa.save
        format.html { redirect_to @rfa, notice: "Rfa was successfully created." }
        format.json { render :show, status: :created, location: @rfa }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @rfa.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rfas/1 or /rfas/1.json
  def update
    respond_to do |format|
      if @rfa.update(rfa_params)
        format.html { redirect_to @rfa, notice: "Rfa was successfully updated." }
        format.json { render :show, status: :ok, location: @rfa }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @rfa.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rfas/1 or /rfas/1.json
  def destroy
    @rfa.destroy
    respond_to do |format|
      format.html { redirect_to rfas_url, notice: "Rfa was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rfa
      @rfa = Rfa.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def rfa_params
      params.require(:rfa).permit(:title, :description, :rsi_username, :status_id, 
      :location_id, :ship_id, :priority_id, :total_fuel, :total_price, :total_cost, 
      :aec_rewards, :user_assigned_id)      
    end
end
