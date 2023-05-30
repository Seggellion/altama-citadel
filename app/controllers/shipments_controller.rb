class ShipmentsController < ApplicationController
  skip_before_action :verify_authenticity_token
  #skip_before_action :require_login, only: [:json_request]

  
  
  def json_request
    # Parse the incoming JSON request
    
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



buy_search_query = "#{commodity_name} #{from_location}"
buy_commodity = Commodity.search_by_name_and_location(buy_search_query).order(updated_at: :desc).first
sell_search_query = "#{commodity_name} #{to_location}"
sell_commodity = Commodity.search_by_name_and_location(sell_search_query).order(updated_at: :desc).first


puts sell_commodity.buy
puts buy_commodity.sell

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

puts total_profit 
puts total_units.to_i

    # Render the response
    render json: response
  end
end