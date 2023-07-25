class StarBitizenController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def buy_trade
    json_request = JSON.parse(request.body.read)
    @secretguid  = ENV['STARBITIZEN_EXCHANGE']
    commodity_name = json_request["commodity"]
    received_guid = json_request["secretguid"]  
    starbits = json_request["starbits"].to_i
    
    return unless @secretguid == received_guid  
    @active_commodities = Commodity.where(active:true)
    player_name = json_request["player_name"]
    from_location = json_request["from_location"]
    to_location = json_request["to_location"]

    sell_search_query = "#{commodity_name} #{to_location}"
    # sell_commodity = @active_commodities.search_by_name_and_location(sell_search_query).min_by { |commodity| (commodity.updated_at - Time.current).abs }
    sell_commodity = @active_commodities.search_by_name_and_location(sell_search_query).where('buy > ?', 0)
    
    total_units = json_request["total_units"].to_i
    to_user = User.where("lower(username) LIKE lower(?)", "%#{player_name.downcase}%").first_or_initialize
  
    if to_user.new_record?      
      to_user.username = player_name
      to_user.password = SecureRandom.hex(10) 
      to_user.provider = 'StarBitizen' # replace with actual values
      to_user.save!      
    end
  
    buy_search_query = "#{commodity_name} #{from_location}"
  
   # buy_commodity = @active_commodities.search_by_name_and_location(buy_search_query).min_by { |commodity| (commodity.updated_at - Time.current).abs }
    buy_commodity = @active_commodities.search_by_name_and_location(buy_search_query).where('sell > ?', 0)
    to_user_id = User.where('lower(username) = lower(?)', player_name).first.id  
  
    records_exist = buy_commodity.present? && sell_commodity.present?
    
    if records_exist &&  buy_commodity.inventory > 0
      actual_removed = [buy_commodity.maxInventory, total_units].min
      actual_removed = [buy_commodity.inventory, actual_removed].min
  
      # Now calculate the capital
      capital = buy_commodity.sell.to_i * actual_removed
  
      if capital <= starbits
        buy_commodity_inventory = buy_commodity.decrement!(:inventory, actual_removed)    
        buy_commodity.save
        total_profit = 0
        existing_run = StarBitizenRun.find_by(user_id: to_user_id, profit:0)
  
        if existing_run && existing_run.created_at < (Time.now - 4.minutes)      
          existing_run.destroy
          StarBitizenRun.create(
            commodity_id: buy_commodity.id,
            user_id: to_user_id, 
            profit: total_profit,
            scu: actual_removed)   
        else
          StarBitizenRun.create(
            commodity_id: buy_commodity.id,
            user_id: to_user_id, 
            profit: total_profit,
            scu: actual_removed)
        end
  
        response = {capital:  capital  }
      else
        response = {capital:  'insufficient_funds' }
      end
    elsif records_exist &&  buy_commodity.inventory == 0
      response = {capital:  'insufficient_inventory' }
    else
      
      response = {capital:  'invalid' }
    end
    
    render json: response
  end
  


def sell_trade
  json_request = JSON.parse(request.body.read)
  @secretguid  = ENV['STARBITIZEN_EXCHANGE']
  received_guid = json_request["secretguid"]  
  
  return unless @secretguid == received_guid  
  player_name = json_request["player_name"]  
  
  to_user_id = User.find_by(username: player_name)
  commodity_name = json_request["commodity"]
  @active_commodities = Commodity.where(active:true)

  to_location = json_request["to_location"]
  total_units = json_request["total_units"].to_i
  sell_search_query = "#{commodity_name} #{to_location}"

#is it possible sell_commodity does not exist?

  sell_commodity =  @active_commodities.search_by_name_and_location(sell_search_query).min_by { |commodity| (commodity.updated_at - Time.current).abs }
  records_exist = sell_commodity.present?
  current_run = StarBitizenRun.find_by(user_id: to_user_id, profit: 0) 

  if records_exist &&  current_run
    total_units = current_run.scu
    capital = current_run.commodity.sell.to_i * total_units
    total_profit = ( sell_commodity.buy.to_i * total_units) - ( capital)
    total_sold = total_profit + capital
    current_run.update(profit:total_profit)

    response = {total_sold:  total_sold}
  else
    response = {total_sold:  'invalid'  }
  end

  render json: response

end


def profit_check
    json_request = JSON.parse(request.body.read)
    commodity_name = json_request["commodity"]
    from_location = json_request["from_location"]
    to_location = json_request["to_location"]
    total_units = json_request["total_units"]


  buy_search_query = "#{commodity_name} #{from_location}"
  buy_commodity = @active_commodities.search_by_name_and_location(buy_search_query).min_by { |commodity| (commodity.updated_at - Time.current).abs }
  sell_search_query = "#{commodity_name} #{to_location}"
  sell_commodity = @active_commodities.search_by_name_and_location(sell_search_query).min_by { |commodity| (commodity.updated_at - Time.current).abs }

    records_exist = buy_commodity.present? && sell_commodity.present?
    if records_exist
      total_profit = ( sell_commodity.buy.to_i * total_units.to_i) - ( buy_commodity.sell.to_i * total_units.to_i)
      response = {total_profit:  total_profit  }
    else
      response = {total_profit:  'invalid' }
    end


    # Render the response
    render json: response
  end



end