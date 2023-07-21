class StarBitizenController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def json_request
    @secretguid  = ENV['STARBITIZEN_EXCHANGE']
    json_request = JSON.parse(request.body.read)

    player_name = json_request["player_name"]    
    star_bits = json_request["starBits"].to_i
    received_guid = json_request["secretguid"]
    return unless @secretguid == received_guid  
    sell_complete = json_request["sell_complete"]
    commodity_name = json_request["commodity"]
    from_location = json_request["from_location"]
    to_location = json_request["to_location"]
    total_units = json_request["total_units"].to_i

    to_user = User.where("lower(username) LIKE lower(?)", "%#{player_name.downcase}%").first_or_initialize

    buy_search_query = "#{commodity_name} #{from_location}"

    buy_commodity = Commodity.search_by_name_and_location(buy_search_query).min_by { |commodity| (commodity.updated_at - Time.current).abs }
    sell_search_query = "#{commodity_name} #{to_location}"
    sell_commodity = Commodity.search_by_name_and_location(sell_search_query).min_by { |commodity| (commodity.updated_at - Time.current).abs }
    
    

    if to_user.new_record?      
      to_user.password = SecureRandom.hex(10) 
      to_user.provider = 'StarBitizen' # replace with actual values
      to_user.save!      
    end
    
    to_user_id = User.where('lower(username) = lower(?)', player_name).first.id  


    records_exist = buy_commodity.present? && sell_commodity.present?

    
    if records_exist
      # Calculate how much to actually remove
      
      actual_removed = [buy_commodity.maxInventory, total_units].min

actual_removed = [buy_commodity.inventory, actual_removed].min
capital = buy_commodity.sell.to_i * actual_removed

    buy_commodity_inventory = buy_commodity.decrement!(:inventory, actual_removed)
    
    buy_commodity.save

    
    if sell_complete
      total_profit = ( sell_commodity.buy.to_i * actual_removed) - ( capital)
    else
      actual_removed = 0
      total_profit = 0
    end
      
            
    # transaction = Transaction.create(amount: star_bits, sender_id: from_user_id, receiver_id: to_user_id)
    StarBitizenRun.find_or_create_by(commodity_id: buy_commodity.id, user_id: to_user_id, profit: 0) do |run|
      run.profit = total_profit
      run.scu = actual_removed
    end
    response = {total_profit:  total_profit  }

    else
      response = {total_profit:  'invalid' }
    end

  



 #   response = {total_aec:  to_user.aec  }    
    render json: response
  end
end