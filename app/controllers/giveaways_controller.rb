class GiveawaysController < ApplicationController
  include GiveawayAdminAuthorization

  before_action :require_giveaway_admin
  before_action :set_bot
  before_action :set_giveaway, only: %i[edit update destroy]

  def create
    @giveaway = @bot.giveaways.new(giveaway_params)

    if @giveaway.save
      redirect_to return_path(@giveaway), notice: "Giveaway \"#{@giveaway.title}\" created (!#{@giveaway.command_name}).", status: :see_other
    else
      # The form lives in the ALTAMA.EXE window (or the Extra Life event window), so report the validation errors there.
      redirect_to return_path(@giveaway, selected: "new"), alert: "Giveaway not created: #{@giveaway.errors.full_messages.to_sentence}", status: :see_other
    end
  end

  def edit
  end

  def update
    if @giveaway.update(giveaway_params)
      redirect_to return_path(@giveaway), notice: "Giveaway updated.", status: :see_other
    else
      redirect_to return_path(@giveaway), alert: "Giveaway not updated: #{@giveaway.errors.full_messages.to_sentence}", status: :see_other
    end
  end

  def destroy
    if @giveaway.destroy
      redirect_to return_path(@giveaway, selected: nil), notice: "Giveaway deleted.", status: :see_other
    else
      redirect_to return_path(@giveaway), alert: "Giveaway not deleted: #{@giveaway.errors.full_messages.to_sentence}", status: :see_other
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

  # Back to where the form was: the event window's Prizes tab, or the Bot Manager window with the giveaway selected.
  def return_path(giveaway, selected: :self)
    event = giveaway.extra_life_event
    if params[:return_to] == "event" && event && event.bot_id == @bot.id
      return bot_extra_life_event_path(@bot, event, tab: "prizes")
    end

    selected = giveaway.persisted? ? "g#{giveaway.id}" : nil if selected == :self
    desktop_path({ bexe_tab: "giveaways", bexe_giveaway: selected }.compact)
  end
end
