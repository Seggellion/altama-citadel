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
    @position_nomination = PositionNomination.new(position_nomination_params)
    nominator_id = current_user
    guildstone_id = 1
    respond_to do |format|
      if @position_nomination.save
        format.html { redirect_to @position_nomination, notice: "PositionNomination was successfully created." }
        format.json { render :show, status: :created, location: @position_nomination }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @position_nomination.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @position_nomination.destroy
    respond_to do |format|
      format.html { redirect_to position_nominations_url, notice: "PositionNomination was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def update
    respond_to do |format|
      if @position_nomination.update(position_nomination_params)
        format.html { redirect_to @position_nomination, notice: "PositionNomination was successfully updated." }
        format.json { render :show, status: :ok, location: @position_nomination }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @position_nomination.errors, status: :unprocessable_entity }
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
    params.require(:position_nomination).permit(:position_id, :nominee_id, :campaign_description, :resume)
  end

  


end