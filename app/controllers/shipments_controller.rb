class ShipmentsController < ApplicationController
  skip_before_action :verify_authenticity_token
  #skip_before_action :require_login, only: [:json_request]

  
  
  def json_request
    # Parse the incoming JSON request
    @active_commodities = Commodity.where(active:true)
    json_request = JSON.parse(request.body.read)

    # Extract the required parameters from the request
    commodity_name = json_request["commodity"]
    from_location = json_request["from_location"]
    to_location = json_request["to_location"]
    total_units = json_request["total_units"]


# buy_commodity = Commodity.where("location LIKE ? AND name = ?", "%#{from_location}%", commodity_name).first
# sell_commodity = Commodity.where("location LIKE ? AND name = ?", "%#{to_location}%", commodity_name).first

#buy_commodity = Commodity.where("location LIKE ? AND name ILIKE ?", "%#{from_location}%", "%#{commodity_name}%").first
# sell_commodity = Commodity.where("location LIKE ? AND name ILIKE ?", "%#{to_location}%", "%#{commodity_name}%").first




#buy_commodity = @active_commodities.search_by_name_and_location(buy_search_query).where('sell > ?', 0).first
#buy_commodity = Commodity.search_by_name_and_location(buy_search_query).order("DATE(updated_at) DESC").first
#buy_commodity = @active_commodities.search_by_name_and_location(buy_search_query).min_by { |commodity| (commodity.updated_at - Time.current).abs }

#sell_commodity = @active_commodities.search_by_name_and_location(sell_search_query).where('buy > ?', 0).first


sell_search_query = "#{commodity_name} #{to_location}"
buy_search_query = "#{commodity_name} #{from_location}"
buy_commodity = @active_commodities
               .search_by_exact_name(buy_search_query[:name])
               .search_by_location(buy_search_query[:location])
               .where('sell > ?', 0)
               .first

sell_commodity = @active_commodities
                .search_by_exact_name(sell_search_query[:name])
                .search_by_location(sell_search_query[:location])
                .where('buy > ?', 0)
                .first

#if buy_commodity && buy_commodity.sell > 0 &&  sell_commodity && sell_commodity.buy > 0 
    #total_profit = ( sell_commodity.buy.to_f * total_units) - ( buy_commodity.sell.to_f * total_units)
#else
#  wrong_stuff = {error: "Total profit"}
#  render json: wrong_stuff
  # return false
#end
    

    # Check if records exist in the database
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