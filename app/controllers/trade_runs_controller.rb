class TradeRunsController < ApplicationController


    def create
        




if params[:trade_run][:split]

    TradeRun.create!(
        trade_session_id: params[:trade_run][:trade_session_id],
        username: params[:trade_run][:username],
        ship: params[:trade_run][:ship],
        usership_id: params[:trade_run][:user_ship],
        split: params[:trade_run][:split],
        locked: params[:trade_run][:locked],
        delta: params[:trade_run][:delta],
        profit: params[:trade_run][:profit],
        buy_location: params[:trade_run][:buy_location],
        sell_location: params[:trade_run][:sell_location],
        payout_complete: params[:trade_run][:payout_complete],
        last_updated: Time.now
    )

    commodities = JSON.parse(params[:trade_run][:split_cmdty_json])

    commodities.each do |commodity|
        TradeRunSplit.create!(
          buy_price: commodity["commodity_buy"],
          sell_price: commodity["commodity_sell"],
          scu: commodity["scu"],
          commodity_id: commodity["commodity_id"],
           traderun_id: TradeRun.last.id
        )
      end


else
    commodity_id =  Commodity.find_by(name: params[:trade_run][:buy_commodity],location: params[:trade_run][:buy_location]).id
    TradeRun.create(
        trade_session_id: params[:trade_run][:trade_session_id],
        username: params[:trade_run][:username],
        ship: params[:trade_run][:ship],
        usership_id: params[:trade_run][:user_ship],
        split: params[:trade_run][:split],
        commodity_id: commodity_id,
        scu: params[:trade_run][:scu],
        locked: params[:trade_run][:locked],
        delta: params[:trade_run][:delta],
        buy_location: params[:trade_run][:buy_location],
        sell_location: params[:trade_run][:sell_location],
        buy_price: params[:trade_run][:buy_price],
        sell_price: params[:trade_run][:sell_price],
        profit: params[:trade_run][:profit],
        payout_complete: params[:trade_run][:payout_complete],
        last_updated: Time.now,
    )


end

        

            redirect_to root_path
    end

end