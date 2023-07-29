class StreamchartController < ApplicationController
    # before_action :authenticate_user!
    # before_action :not_logged_in
    
    def payout
        @trade_session = TradeSession.find_by_id(5)
        @trade_session = TradeSession.find_by_id(params[:format])
        @trade_runs = TradeRun.where(trade_session_id: @trade_session)
        @session_users =  @trade_runs.map(&:username)
        @user_payout = @session_users.map do |username|
            user_trade_runs = @trade_runs.select { |trade_run| trade_run.username == username }
            user_total_payout = user_trade_runs.inject(0) { |sum, trade_run| sum + trade_run.payout }
            user_total_payout
          end
        render "trade123/streamchart"
    end
    
    def milkrun_profits
      trade_session_id = params[:trade_session_id]
      render json: MilkRun.where(trade_session_id: trade_session_id).joins(:user).group('users.username').sum(:profit)
    end

    def star_bitizen_runs_data
      profits = StarBitizenRun.all.joins(:user).group('users.username').sum(:profit)
      runs = StarBitizenRun.all.joins(:user).group('users.username').count
      render json: { profits: profits, runs: runs }
    end
    
  
    def traderun_profits
         
      trade_session_id = params[:trade_session_id]
      render json: TradeRun.where(trade_session_id: trade_session_id).joins(:user).group('users.username').sum(:profit)
    end

    def star_bitizen

    end
  
    
    end