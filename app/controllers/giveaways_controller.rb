class GiveawaysController < ApplicationController
    before_action :set_bot
  
    def new
      @giveaway = @bot.giveaways.new
    end
  
    def create
      @giveaway = @bot.giveaways.new(giveaway_params)
  
      if @giveaway.save
        redirect_to bot_path(@bot), notice: 'Giveaway was successfully created.'
      else
        redirect_to root_path
      end
    end
  
    def show
      @giveaway = @bot.giveaways.find(params[:id])
    end
  
    private
  
    def set_bot
      @bot = Bot.find(params[:bot_id])
    end
  
    def giveaway_params
      params.require(:giveaway).permit(:title, :description)
    end
  end
  