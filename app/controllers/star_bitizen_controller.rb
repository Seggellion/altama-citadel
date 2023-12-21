class StarBitizenController < ApplicationController
    include JsonRequestParser
    include GuidValidator
  
    skip_before_action :verify_authenticity_token
    before_action :parse_json_request, :validate_secret_guid
  
    def buy_trade
    setup_buy_trade_variables
    
      processor = BuyTradeProcessor.new(@buy_commodity, @sell_commodity, @twitch_channel, @total_units, @to_user, @starbits)      
      render json: processor.process
    rescue => e
      
      log_error("buy_trade", e)
    end
  
    def sell_trade
      setup_sell_trade_variables

      processor = SellTradeProcessor.new(@sell_commodity, @current_run)
      render json: processor.process
    rescue => e
      log_error("sell_trade", e)
    end
  
    private
  
    def setup_buy_trade_variables

        @commodity_name = @json_request["commodity"]
        @starbits = @json_request["starbits"].to_i
        @twitch_channel = @json_request["twitch_channel"]
        @trade_locations = Location.where(trade_terminal: true)
        player_name = @json_request["player_name"]
      
        from_location_string = @json_request["from_location"]
        from_location = @trade_locations.search_for(from_location_string).first&.name
        to_location_string = @json_request["to_location"]
        to_location = @trade_locations.search_for(to_location_string).first&.name

        @sell_commodity = Commodity.where(name: @commodity_name, location: to_location).where('buy > ?', 0).first
        @buy_commodity = Commodity.where(name: @commodity_name, location: from_location).where('sell > ?', 0).first
        @total_units = @json_request["total_units"].to_i
        @to_user = fetch_or_create_user(player_name)
        
      end
      
      def fetch_or_create_user(player_name)
        user = User.where("username ILIKE ?", player_name).first_or_initialize do |new_user|
          new_user.username = player_name
          new_user.password = SecureRandom.hex(10) # Generate a random password
          new_user.provider = 'StarBitizen'       # Set the provider or other attributes as needed
        end
    
        user.save! if user.new_record?
        user
      end
  
    def setup_sell_trade_variables
        @current_run = find_current_run
        @commodity_name = @json_request["commodity"]
        @twitch_channel = @json_request["twitch_channel"]
        @trade_locations = Location.where(trade_terminal: true)
        player_name = @json_request["player_name"]
      
        to_location_string = @json_request["to_location"]
        to_location = @trade_locations.search_for(to_location_string).first&.name
      
        @sell_commodity = Commodity.where(name: @commodity_name, location: to_location).where('buy > ?', 0).first
        @to_user = fetch_or_create_user(player_name)
        # Note: If total_units or other variables are needed for sell trades, include them here
      end
      
      def find_current_run
        player_name = @json_request["player_name"]
        to_user_id = User.where("username ILIKE ?", player_name).first.id
        @twitch_channel = @json_request["twitch_channel"].to_i
        StarBitizenRun.find_by(user_id: to_user_id, twitch_channel: @twitch_channel, profit: 0)
      end
  
    def log_error(action, exception)
      logger.error "Exception in #{action}: #{exception.message}"
      render json: { error: 'Trade processing error' }, status: :internal_server_error
    end
  end
  