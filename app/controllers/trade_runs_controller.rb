class TradeRunsController < ApplicationController


    def create
        commodity_id =  Commodity.find_by(name: params[:trade_run][:buy_commodity],location: params[:trade_run][:buy_location]).id
        tradesession_id = 1
        
            TradeRun.create(
                tradesession_id: tradesession_id,
                ship: params[:trade_run][:ship],
                username: params[:trade_run][:username],
                ship: params[:trade_run][:ship],
                usership_id: params[:trade_run][:user_ship],
                split: params[:trade_run][:split],
                commodity_id: commodity_id,
                scu: params[:trade_run][:scu],
                locked: params[:trade_run][:locked],
                buy_location: params[:trade_run][:buy_location],
                sell_location: params[:trade_run][:sell_location],
                buy_price: params[:trade_run][:buy_price],
                sell_price: params[:trade_run][:sell_price],
                payout_complete: params[:trade_run][:payout_complete],
                last_updated: Time.now,
            )
            redirect_to root_path
    end

end