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
    
    
    def milk_run_profits
byebug
    end
  
    
    end