class MilkRunsController < ApplicationController
    before_action :task_manager
    def new
        @milk_run = MilkRun.new
        @commodities_for_sell = Commodity.joins(:milk_runs).where.not(milk_runs: { sell_commodity_scu: 0 })
        @locations_for_sell = []
    end
    
    def create
        # Find the existing record
        
       # @milk_run = MilkRun.find(params[:id])
       

        
        trade_session_id = params[:milk_run][:trade_session_id]
        buy_commodity_id = params[:milk_run][:buy_commodity_id]
        
        
        byebug
        if params[:milk_run][:form_type] == "buy"
            existing_milkrun = MilkRun.find_by(buy_commodity_id: buy_commodity_id, sell_commodity_id: nil)
            user = User.search_by_username(params[:user_id]).first
            used_scu =  MilkRun.where(trade_session_id: trade_session_id, user_id: user.id).sum(:buy_commodity_scu)
            unless existing_milkrun
            MilkRun.create!(
                user_id: user.id, 
                usership_id: params[:milk_run][:trade_session_id], 
                trade_session_id: trade_session_id, 
                commodity_name: params[:milk_run][:commodity_name], 
                buy_commodity_id: buy_commodity_id,
                buy_commodity_scu: params[:milk_run][:buy_commodity_scu],
                buy_commodity_price: params[:milk_run][:buy_commodity_price],      
                #max_scu: integer, 
                used_scu:  used_scu,             
                updated_at: Time.now
            )
            end
        elsif params[:milk_run][:form_type] == "sell"
            current_milkrun = MilkRun.find_by(trade_session_id: trade_session_id, buy_commodity_id: buy_commodity_id, sell_commodity_id: nil)
            
            used_scu =  MilkRun.where(trade_session_id: trade_session_id, user_id: @current_user.id).sum(:buy_commodity_scu)
            buy_total = params[:milk_run][:buy_commodity_scu].to_i * params[:milk_run][:buy_commodity_price].to_i
            sell_total = params[:milk_run][:sell_commodity_scu].to_i * params[:milk_run][:sell_commodity_price].to_i
            profit = sell_total - buy_total
            
            current_milkrun.update!(
                sell_commodity_id: params[:milk_run][:sell_commodity_id].to_i,
                sell_commodity_scu: params[:milk_run][:sell_commodity_scu].to_i,
                sell_commodity_price: params[:milk_run][:sell_commodity_price].to_i,          
                used_scu: used_scu, 
                profit: profit, 
                updated_at: Time.now
            )
            
        end


        # Update it with the new data
       # if @milk_run.update(milk_run_params)
       # redirect_to @milk_run
       # else
       # render :new
       # end
       redirect_to MilkRun.last
    end
    
    private
    
    def milk_run_params
        params.require(:milk_run).permit(:sell_commodity_scu, :sell_commodity_price, :profit)
    end
  
end