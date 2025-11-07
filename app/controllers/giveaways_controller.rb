class GiveawaysController < ApplicationController
  before_action :set_bot
  before_action :set_giveaway, only: %i[edit update destroy]

  def create
    @giveaway = @bot.giveaways.new(giveaway_params)

    if @giveaway.save
      redirect_to root_path, notice: "Giveaway created successfully."
    else
      redirect_to root_path, alert: "Failed to create giveaway."
    end
  end

  def edit
  end

  def update
    if @giveaway.update(giveaway_params)
      redirect_to root_path, notice: "Giveaway updated successfully."
    else
      redirect_to root_path, alert: "Failed to update giveaway."
    end
  end

  def destroy
    @giveaway.destroy
    redirect_to desktop_path, notice: "Giveaway deleted."
  end

  private

  def set_bot
    @bot = Bot.find(params[:bot_id])
  end

  def set_giveaway
    @giveaway = @bot.giveaways.find(params[:id])
  end

  def giveaway_params
    params.require(:giveaway).permit(:title, :description, :mode, :cost, :command_name, :channel)
  end
end
