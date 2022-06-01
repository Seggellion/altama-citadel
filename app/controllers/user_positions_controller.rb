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

  # this may be useless
  def reject_nomination
    @guildstone = Guildstone.first
    position = Position.find_by_id(params[:position])
    nomination = PositionNomination.find_by(position_id: position.id, nominee_id:current_user.id)
    nomination.destroy
    redirect_to @guildstone
  end
  # this may be useless
  def accept_nomination
    @guildstone = Guildstone.first
    @my_user_position_histories = UserPositionHistory.where(user_id: current_user.id)
    @my_user_positions = UserPosition.where(user_id: current_user.id)
    position = Position.find_by_id(params[:position])

    nomination = PositionNomination.find_by(position_id: position.id, nominee_id:current_user.id)
    @my_user_position_histories = UserPositionHistory.where(user_id: current_user.id)
    @my_user_positions = UserPosition.where(user_id: current_user.id)
    @my_user_positions.destroy_all
    @my_user_position_histories.update_all(active: false)
    @user_position_history = UserPositionHistory.new(
      user_id: current_user.id,
      title: position.title,
      department_id: position.department_id,
      guildstone_id: @guildstone.id,
      nomination_id: nomination.id,
      active: true,
      position_id: position.id
    )
    @user_position = UserPosition.new(
      user_id: current_user.id,
      title: position.title,
      department_id: position.department_id,
      guildstone_id: @guildstone.id,
      nomination_id: nomination.id,
      position_id: position.id
    )

    respond_to do |format|
      if @user_position.save
        @user_position_history.save
        format.html { redirect_to @guildstone, notice: "Nomination was successfully Accepted." }     
      else
        format.html { redirect_to @guildstone, notice: "Error." }
        
      end
    end

  end

  def create
    @my_user_position_histories = UserPositionHistory.where(user_id: user_position_params[:user_id])
    @my_user_positions = UserPosition.where(user_id: user_position_params[:user_id])
    @my_user_positions.destroy_all
    @user_position_history = UserPositionHistory.new(user_position_params)
    @guildstone = Guildstone.first
    @user_position_history.update(guildstone_id: @guildstone.id)
    @user_position = UserPosition.new(user_position_params)
    @user_position.update(guildstone_id: @guildstone.id)
    @user_position.update(user_id: user_position_params[:user_id])
    @my_user_position_histories.update_all(active: false)
    @user_position_history.update(active: true)
   
    respond_to do |format|
      if @user_position.save
        @user_position_history.save
        format.html { redirect_to @guildstone, notice: "Position was successfully Assigned." }     
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
    params.require(:user_position).permit(:user_id, :guildstone_id, :description, :title, :department_id, :nomination_id, :compensation, :position_id, :term_end, :active)
  end





end