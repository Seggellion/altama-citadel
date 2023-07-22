class StarBitizenController < ApplicationController
  skip_before_action :verify_authenticity_token
  
def buy_trade
  json_request = JSON.parse(request.body.read)
  @secretguid  = ENV['STARBITIZEN_EXCHANGE']
  commodity_name = json_request["commodity"]
  received_guid = json_request["secretguid"]  
  
  return unless @secretguid == received_guid  

  json_request = JSON.parse(request.body.read)
  player_name = json_request["player_name"]
  from_location = json_request["from_location"]
  total_units = json_request["total_units"].to_i
  to_user = User.where("lower(username) LIKE lower(?)", "%#{player_name.downcase}%").first_or_initialize

  if to_user.new_record?      
    to_user.username = player_name
    to_user.password = SecureRandom.hex(10) 
    to_user.provider = 'StarBitizen' # replace with actual values
    to_user.save!      
  end

  buy_search_query = "#{commodity_name} #{from_location}"

  buy_commodity = Commodity.search_by_name_and_location(buy_search_query).min_by { |commodity| (commodity.updated_at - Time.current).abs }

  to_user_id = User.where('lower(username) = lower(?)', player_name).first.id  

  records_exist = buy_commodity.present?
    
    if records_exist &&  buy_commodity.inventory > 0

      actual_removed = [buy_commodity.maxInventory, total_units].min

      actual_removed = [buy_commodity.inventory, actual_removed].min
      capital = buy_commodity.sell.to_i * actual_removed

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
    elsif existing_run && existing_run.created_at > (Time.now - 4.minutes)
      
    else
      StarBitizenRun.create(
        commodity_id: buy_commodity.id,
        user_id: to_user_id, 
        profit: total_profit,
        scu: actual_removed)
    end

    response = {total_profit:  total_profit  }

    else
      response = {total_profit:  'invalid' }
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

  to_location = json_request["to_location"]
  total_units = json_request["total_units"].to_i
  sell_search_query = "#{commodity_name} #{to_location}"
  sell_commodity = Commodity.search_by_name_and_location(sell_search_query).min_by { |commodity| (commodity.updated_at - Time.current).abs }
  
  

  records_exist = sell_commodity.present?

  if records_exist
    current_run = StarBitizenRun.find_by(user_id: to_user_id, profit: 0) 
    total_units = current_run.scu
    capital = current_run.commodity.sell.to_i * total_units
    total_profit = ( sell_commodity.buy.to_i * total_units) - ( capital)

    current_run.update(profit:total_profit)
    response = {total_profit:  total_profit  }
  else
    response = {total_profit:  'invalid'  }
  end

  render json: response

end


end