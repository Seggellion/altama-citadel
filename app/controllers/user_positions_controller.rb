class UserPositionsController < ApplicationController

  before_action :set_user_position, only: %i[ show edit update destroy ]

  def show
  end

  def index
    @user_positions = UserPosition.all
  end

  def new
    @user_position = UserPosition.new
  end

  def create
    @user_position = UserPosition.new(user_position_params)
    @guildstone = Guildstone.first
    @user_position.update(guildstone_id: @guildstone.id)
    @user_position.update(user_id: current_user.id)
    respond_to do |format|
      if @user_position.save
        format.html { redirect_to @guildstone, notice: "Position was successfully Applied." }
        
      else
        format.html { redirect_to @guildstone, notice: "Error." }
        
      end
    end
  end

  def destroy
    @user_position.destroy
    respond_to do |format|
      format.html { redirect_to user_positions_url, notice: "User Position was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def update
    respond_to do |format|
      if @user_position.update(user_position_params)
        format.html { redirect_to @user_position, notice: "User Position was successfully updated." }
        format.json { render :show, status: :ok, location: @user_position }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user_position.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user_position
    @user_position = UserPosition.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def user_position_params

    params.require(:user_position).permit(:user_id, :guildstone_id, :description, :title, :department_id, :nomination_id, :compensation, :position_id, :term_end)

  end

  


end