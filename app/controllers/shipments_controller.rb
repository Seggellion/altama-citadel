class ShipmentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:json_request]
  skip_before_action :require_login, only: [:action_name]
  
  def json_request
    # Parse the incoming JSON request
    
    json_request = JSON.parse(request.body.read)

    # Extract the required parameters from the request
    commodity = json_request["commodity"]
    from_location = json_request["from_location"]
    to_location = json_request["to_location"]
    total_units = json_request["total_units"].to_f * 100


buy_commodity = Commodity.where("location LIKE ? AND name = ?", "%#{from_location}%", commodity).first
sell_commodity = Commodity.where("location LIKE ? AND name = ?", "%#{to_location}%", commodity).first


    total_profit = ( sell_commodity.buy.to_f * total_units) - ( buy_commodity.sell.to_f * total_units)

    

    # Check if records exist in the database
    records_exist = buy_commodity.present? && sell_commodity.present?
if records_exist
  response = {total_profit:  total_profit  }
else
  response = {total_profit:  0  }
end
    # Build the JSON response

    

    # Render the response
    render json: response
  end
end