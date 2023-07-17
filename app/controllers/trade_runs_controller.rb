class TradeRunsController < ApplicationController
    protect_from_forgery except: :create

def show
redirect_to root_path
end


    def create
        
    if params[:trade_run][:split] == 'true'

        TradeRun.create!(
            trade_session_id: params[:trade_run][:trade_session_id],
            username: params[:trade_run][:username],
            ship: params[:trade_run][:ship],
            usership_id: params[:trade_run][:user_ship],
            split: params[:trade_run][:split],
            locked: params[:trade_run][:locked],
            delta: params[:trade_run][:delta],
            profit: params[:trade_run][:profit],
            scu: params[:trade_run][:scu],
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

    def update
        @trade_run = TradeRun.find(params[:id])
        # Ensure the sell_price is in the params
        
        if trade_run_params[:sell_price]
          # Calculate the profit
          sell_price = trade_run_params[:sell_price].to_f
          buy_price = @trade_run.buy_price
          quantity = @trade_run.scu
          profit = (sell_price - buy_price) * quantity
      
          # Add the profit to the params
          trade_run_params_with_profit = trade_run_params.merge(profit: profit)
        else
          trade_run_params_with_profit = trade_run_params
        end
      
        if @trade_run.update(trade_run_params_with_profit)
          response = {status: 'ok', profit: @trade_run.profit}
          Rails.logger.debug "Response: #{response}"
          render json: response
        else
          response = {status: 'error', errors: @trade_run.errors.full_messages}
          Rails.logger.debug "Response: #{response}"
          render json: response, status: 422
        end
      end
      
      def update_traderun_location
        @trade_run = TradeRun.find(params[:id])
        @commodity_buy_price = Commodity.find_by(location: params[:trade_run][:sell_location], name: @trade_run.commodity.name).buy
        if @trade_run.update(trade_run_location_params)
            
            render json: {status: 'ok', location: @trade_run.sell_location, buy_price: @commodity_buy_price}
        else
            response = {status: 'error', errors: @trade_run.errors.full_messages}
            Rails.logger.debug "Response: #{response}"
            render json: response, status: 422
        end
    end
    



# app/controllers/trade_runs_controller.rb

def destroy
    @trade_run = TradeRun.find(params[:id])

    @trade_run.destroy
  
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Trade run was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  

private

def trade_run_params
    params.require(:trade_run).permit(:username, :ship, :buy_location, :sell_price, :buy_price, :scu)
end

    
def trade_run_location_params
    params.require(:trade_run).permit(:sell_location)
end

end