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
    user_id = current_user
    @user_position = UserPosition.new(user_position_params)

    respond_to do |format|
      if @user_position.save
        format.html { redirect_to @user_position, notice: "User Position was successfully created." }
        format.json { render :show, status: :created, location: @user_position }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user_position.errors, status: :unprocessable_entity }
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
    params.fetch(:user_position, {})
  end

  


end