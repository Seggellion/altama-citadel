class AcuExchangeController < ApplicationController
  skip_before_action :verify_authenticity_token
  #skip_before_action :require_login, only: [:json_request]
  
  def json_request
    # Parse the incoming JSON request

  @secretguid  = ENV['STARBITIZEN_EXCHANGE']

  # Create new transaction
  # update user AEC value

    json_request = JSON.parse(request.body.read)

    # Extract the required parameters from the request
    player_name = json_request["playerName"]    
    star_bits = json_request["starBits"].to_i
    received_guid = json_request["secretguid"]
    

    from_user_id = 1    
    to_user = User.find_or_initialize_by(username: player_name)
    if to_user.new_record?
      
      # Set additional attributes here
      to_user.password = SecureRandom.hex(10) 
      to_user.provider = 'Twitch' # replace with actual values
      to_user.save!
      
    end

    
    to_user_id = User.find_by_username(player_name).id
    return unless @secretguid == received_guid
    transaction = Transaction.create(amount: star_bits, sender_id: from_user_id, receiver_id: to_user_id)
    
    if transaction.persisted?
      
      to_user.increment!(:aec, star_bits)
    else
      throw :abort
    end



    response = {total_aec:  to_user.aec  }

    
    render json: response
  end
end