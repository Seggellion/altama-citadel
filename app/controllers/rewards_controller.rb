class RewardsController < ApplicationController
  before_action :set_reward, only: %i[edit update destroy ]

def create
    @reward = Reward.new(reward_params)
    

    respond_to do |format|
      if @reward.save
        format.html { redirect_to desktop_path, notice: "reward was successfully created." }
        format.json { render :show, status: :created, location: @reward }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @reward.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy

    
    @reward.destroy
    respond_to do |format|
      format.html { redirect_to desktop_path, notice: "Removed reward" }
      format.json { head :no_content }
    end
  end

  private

  def set_reward
    @reward = Reward.find(params[:id])
    
  end


def reward_params
  params.require(:reward).permit(:title, :amount) 
end


end