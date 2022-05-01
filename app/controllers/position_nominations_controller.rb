class PositionNominationsController < ApplicationController

  before_action :set_position_nomination, only: %i[ show edit update destroy ]

  def show
  end

  def index
    @position_nominations = PositionNomination.all
  end

  def new
    @position_nomination = PositionNomination.new
  end

  def create
    nominator_id = current_user
    @guildstone = Guildstone.first
    @position_nomination = PositionNomination.new(position_nomination_params)
    @position_nomination.update(guildstone_id: @guildstone.id)

    respond_to do |format|
      if @position_nomination.save
        format.html { redirect_to request.referrer, notice: "Position Nomination was successfully created." }
       
      else
        format.html { redirect_to request.referrer, notice: "Error." }
    
      end
    end
  end

  def destroy
    @position_nomination.destroy
    respond_to do |format|
      format.html { redirect_to @guildstone, notice: "Position Nomination was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def update
    respond_to do |format|
      if @position_nomination.update(position_nomination_params)
        format.html { redirect_to @guildstone, notice: "Position Nomination was successfully updated." }
       
      else
        format.html { redirect_to @guildstone, notice: "Error." }
    
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_position_nomination
    @position_nomination = PositionNomination.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def position_nomination_params
    params.require(:position_nomination).permit(:guildstone_id, :position_id, :nominee_id, :campaign_description, :resume)
  end

  


end