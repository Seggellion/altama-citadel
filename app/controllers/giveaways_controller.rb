class GiveawaysController < ApplicationController
  before_action :set_bot
  before_action :set_giveaway, only: %i[edit update destroy]

def create
    @giveaway = @bot.giveaways.new(giveaway_params)

    if @giveaway.save
      # Add status: :see_other to make Turbo happy on success
      redirect_to root_path, notice: "Giveaway created successfully.", status: :see_other
    else
      # Re-render the form with a 422 status code so Turbo can display the errors.
      # (Note: This assumes your form is on a 'new.html.erb' template. If this form 
      # lives on a dashboard or modal, you may need to render that specific view instead.)
      render :new, status: :unprocessable_entity
      
      # OR, if you strictly want to redirect and wipe their input, you still need the 303:
      # redirect_to root_path, alert: "Failed to create giveaway.", status: :see_other
    end
  end

  def edit
  end

  def update
    if @giveaway.update(giveaway_params)
      redirect_to root_path, notice: "Giveaway updated successfully.", status: :see_other
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
