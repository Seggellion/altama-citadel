class UserPositionHistoriesController < ApplicationController
  before_action :set_user_position_history, only: %i[ show edit update destroy ]

  def show
  end

  def index
    @user_position_histories = UserPositionHistory.all
  end

  def new
    @user_position_history = UserPositionHistory.new
  end

  def create
    @user_position_history = UserPositionHistory.new(user_position_history_params)

    respond_to do |format|
      if @user_position_history.save
        format.html { redirect_to @user_position_history, notice: "User Position History was successfully created." }
        format.json { render :show, status: :created, location: @user_position_history }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user_position_history.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user_position_history.destroy
    respond_to do |format|
      format.html { redirect_to user_position_histories_url, notice: "Rule was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def update
    respond_to do |format|
      if @user_position_history.update(user_position_history_params)
        format.html { redirect_to @user_position_histories_url, notice: "User Position History was successfully updated." }
        format.json { render :show, status: :ok, location: @user_position_history }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user_position_history.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user_position_history
    @user_position_history = UserPositionHistory.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def user_position_history_params
    params.fetch(:user_position_history, {})
  end

  


end