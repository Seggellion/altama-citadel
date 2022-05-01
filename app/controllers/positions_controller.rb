class PositionsController < ApplicationController


  before_action :set_position, only: %i[ show edit update destroy ]

  def show
  end

  def index
    @positions = Position.all
  end

  def new
    @position = Position.new
  end

  def create
    @position = Position.new(position_params)
    @guildstone = Guildstone.first
    respond_to do |format|
      if @position.save
        format.html { redirect_to @guildstone, notice: "Position was successfully created." }
        
      else
        format.html { redirect_to @guildstone, notice: "Error." }
        
      end
    end
  end

  def destroy
    @position.destroy
    respond_to do |format|
      format.html { redirect_to positions_url, notice: "Position was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def update
    respond_to do |format|
      if @position.update(position_params)
        format.html { redirect_to @position, notice: "Position was successfully updated." }
        format.json { render :show, status: :ok, location: @position }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @position.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_position
    @position = Position.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def position_params
    params.require(:position).permit(:title, :description, :department_id, :compensation, :parent_position_id)
  end

  

  

end