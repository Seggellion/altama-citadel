class MilkRunsController < ApplicationController
    before_action :task_manager, except: [:create, :profits]
    def new
        @milk_run = MilkRun.new
       # @commodities_for_sell = Commodity.joins(:milk_runs).where.not(milk_runs: { sell_commodity_scu: 0 })
       @commodities_for_sell = Commodity.joins(milk_runs: :user)
                                  .where.not(milk_runs: { sell_commodity_scu: 0, sell_commodity_id: nil })
                                  .select('commodities.*, users.username')

        @locations_for_sell = []
    end
    def profits
        render json: MilkRun.joins(:user).group('users.username').sum(:profit)
    end
    
    def show
        redirect_to root_path
        end
        

        def create                              
            trade_session_id = params[:milk_run][:trade_session_id]
            buy_commodity_id = params[:milk_run][:buy_commodity_id]                      
            
            if params[:milk_run][:form_type] == "buy"
            ship_scu = Ship.find(params[:milk_run][:ship_id])&.scu
            user = User.search_by_username(params[:milk_run][:user_id]).first
            return if params[:milk_run][:user_id]&.empty?
              existing_milkrun = MilkRun.find_by(buy_commodity_id: buy_commodity_id, sell_commodity_id: nil)
          
              unless existing_milkrun
                create_milk_run_and_update_commodity(user, params, 'buy', trade_session_id, buy_commodity_id, ship_scu, ship_scu)
              end
          
            elsif params[:milk_run][:form_type] == "sell"
              current_milkrun = MilkRun.find_by(trade_session_id: trade_session_id, buy_commodity_id: buy_commodity_id, sell_commodity_id: nil)
              if @current_user
                commodity_user_id = @current_user.id 
              else
                commodity_user_id = current_milkrun.user_id
              end
              sell_commodity = Commodity.find_by_id(params[:milk_run][:sell_commodity_id])
              buy_commodity_scu = current_milkrun.buy_commodity_scu
              sell_commodity_scu = params[:milk_run][:sell_commodity_scu].to_i
              buy_commodity_price = current_milkrun.buy_commodity_price
              
              sell_location = JSON.parse(params[:milk_run][:sell_location])["name"].split('| ')[1]              
              used_scu = MilkRun.where(trade_session_id: trade_session_id, user_id: commodity_user_id, sell_commodity_id:nil).sum(:buy_commodity_scu)
              buy_total = buy_commodity_scu * buy_commodity_price
              sell_total = sell_commodity_scu * params[:milk_run][:sell_commodity_price].to_i
              profit = sell_total - buy_total
          

          if sell_commodity_scu < buy_commodity_scu
            buy_total = sell_commodity_scu * buy_commodity_price
            profit = sell_total - buy_total
            MilkRun.create(
              buy_commodity_id: current_milkrun.buy_commodity_id,
              buy_commodity_scu:sell_commodity_scu,
              buy_commodity_price:current_milkrun.buy_commodity_price,
              buy_location:current_milkrun.buy_location,
              usership_id: current_milkrun.usership_id,
              user_id: current_milkrun.user_id,
              trade_session_id:  current_milkrun.trade_session_id,
              sell_commodity_id: sell_commodity.id,
              sell_commodity_scu: sell_commodity_scu,
              commodity_name: current_milkrun.commodity_name,
              sell_commodity_price: params[:milk_run][:sell_commodity_price].to_i, 
              sell_location: sell_location,    
              profit: profit, 
              used_scu: sell_commodity_scu,
            )

            current_milkrun.update!(              
              buy_commodity_scu: buy_commodity_scu - sell_commodity_scu, 
              used_scu: used_scu,               
              updated_at: Time.now
            )

          else

              current_milkrun.update!(
                sell_commodity_id: sell_commodity.id,
                sell_commodity_scu: sell_commodity_scu,
                sell_commodity_price: params[:milk_run][:sell_commodity_price].to_i, 
                sell_location: sell_location,          
                used_scu: used_scu, 
                profit: profit, 
                updated_at: Time.now
              )

          end

              percent_change = ((params[:milk_run][:sell_commodity_price].to_f - sell_commodity.buy) / sell_commodity.buy) * 100                            
              out_of_family = percent_change.abs >= 10       

              if percent_change.abs == 0
                

                if percent_change.abs == 0
                  if params[:milk_run][:public]
                    redirect_to request.original_url and return
                  else
                    redirect_to root_path and return
                  end
                end

              end
              
              #this should be placed below within the else statement to prevent certain entries
              sell_commodity.update(buy: params[:milk_run][:sell_commodity_price], updated_at: Time.now)

                if out_of_family 
                    CommodityStub.create!(user_id: current_milkrun.user_id, commodity_id: sell_commodity.id, buy_price: params[:milk_run][:sell_commodity_price], flagged:true)
                else
                  
                    CommodityStub.create!(user_id: current_milkrun.user_id, commodity_id: sell_commodity.id, buy_price: params[:milk_run][:sell_commodity_price])
                end

            end
          
            
            if params[:milk_run][:public]
              redirect_to request.original_url and return
            else
              redirect_to root_path and return
            end

          end          
    
    def destroy
        milk_run = MilkRun.find_by_id(params[:format])
        milk_run.destroy
        redirect_to root_path
    end

    private
    
   def create_milk_run_and_update_commodity(user, params, trade_type, trade_session_id, commodity_id, ship_scu, used_scu)
            # Create the MilkRun
            MilkRun.create!(
                user_id: user.id, 
                usership_id: params[:milk_run][:trade_session_id], 
                trade_session_id: trade_session_id, 
                commodity_name: params[:milk_run][:commodity_name], 
                "#{trade_type}_commodity_id": commodity_id,
                "#{trade_type}_commodity_scu": params[:milk_run]["#{trade_type}_commodity_scu"],
                "#{trade_type}_commodity_price": params[:milk_run]["#{trade_type}_commodity_price"],
                "#{trade_type}_location": params[:milk_run]["#{trade_type}_location"],      
                max_scu: ship_scu, 
                used_scu:  used_scu,             
                updated_at: Time.now
            )
            
            # Find the relevant Commodity and update it
            commodity = Commodity.find_by_id(commodity_id)
            
            if commodity
              # Calculate the percent change
         #     percent_change = ((params[:milk_run]["#{trade_type}_commodity_price"].to_f - commodity.send(trade_type)) / commodity.send(trade_type)) * 100
         
              percent_change = ((params[:milk_run]["#{trade_type}_commodity_price"].to_f - commodity.sell) / commodity.sell) * 100                            
              out_of_family = percent_change.abs >= 10            
              
              # This has to be reversed because the context changes:
              type_reverse = "sell"
              if trade_type == "buy"
                trade_type = "sell"
                type_reverse = "buy"
              end
              
              #this should be placed below within the else statement to prevent certain entries
            commodity.update("#{trade_type}": params[:milk_run]["#{type_reverse}_commodity_price"], updated_at: Time.now)

if out_of_family 
    CommodityStub.create!(user_id: user.id, commodity_id: commodity.id, "#{trade_type}_price": params[:milk_run]["#{type_reverse}_commodity_price"], flagged:true)
else
    CommodityStub.create!(user_id: user.id, commodity_id: commodity.id, "#{trade_type}_price": params[:milk_run]["#{type_reverse}_commodity_price"])
end
          
              # Create a new CommodityStub
              
            end
          end


    def milk_run_params
        params.require(:milk_run).permit(:sell_commodity_scu, :sell_commodity_price, :profit)
    end
  
end