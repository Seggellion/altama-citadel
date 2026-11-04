class GiveawaysController < ApplicationController
  include GiveawayAdminAuthorization

  before_action :require_giveaway_admin
  before_action :set_bot
  before_action :set_giveaway, only: %i[edit update destroy]

def create
    @giveaway = @bot.giveaways.new(giveaway_params)

    if @giveaway.save
      # Add status: :see_other to make Turbo happy on success
      redirect_to root_path, notice: "Giveaway created successfully.", status: :see_other
    else
      # There is no giveaways/new template (the form lives in the ALTAMA.EXE desktop window), so the old
      # `render :new` raised and production swallowed the error. Report the validation errors instead.
      redirect_to root_path, alert: "Giveaway not created: #{@giveaway.errors.full_messages.to_sentence}", status: :see_other
    end
  end

  def edit
  end

  def update
    if @giveaway.update(giveaway_params)
      redirect_to root_path, notice: "Giveaway updated successfully.", status: :see_other
    else
      redirect_to root_path, alert: "Giveaway not updated: #{@giveaway.errors.full_messages.to_sentence}", status: :see_other
    end
  end

  def destroy
    if @giveaway.destroy
      redirect_to desktop_path, notice: "Giveaway deleted.", status: :see_other
    else
      redirect_to desktop_path, alert: "Giveaway not deleted: #{@giveaway.errors.full_messages.to_sentence}", status: :see_other
    end
  end

  private

  def set_bot
    @bot = Bot.find(params[:bot_id])
  end

  def set_giveaway
    @giveaway = @bot.giveaways.find(params[:id])
  end

  def giveaway_params
    params.require(:giveaway).permit(:title, :description, :mode, :cost, :command_name, :channel, :extra_life_event_id)
  end
end
