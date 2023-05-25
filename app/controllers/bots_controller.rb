class BotsController < ApplicationController
    def index
      @bots = Bot.all
    end
  
    def new
      @bot = Bot.new
    end
  
    def create
      @bot = Bot.new(bot_params)
  
      if @bot.save
        redirect_to root_path, notice: 'Bot was successfully created.'
      else
        redirect_to root_path
      end
    end

    def toggle_online
        @bot = Bot.find(params[:id])
        @bot.update(bot_online: !@bot.bot_online)
    
        redirect_to root_path
      end
  
    private
  
    def bot_params
      params.require(:bot).permit(:channel).merge(bot_name: 'altama_exe')
    end
  end
  