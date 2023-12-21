class TradeProcessor
    def initialize(commodity, current_run, user, units, twitch_channel)
      @commodity = commodity
      @current_run = current_run
      @user = user
      @units = units
      @twitch_channel = twitch_channel
    end
  
    protected
  
    def calculate_profit(buy_price, sell_price)
      (sell_price - buy_price) * @units
    end
  
    def log_trade_activity
      # Log trade activity details here
      puts "Processing trade for commodity: #{@commodity}, units: #{@units}"
    end
  
    def update_commodity_inventory
      # Update commodity inventory based on the trade
      @commodity.decrement!(:inventory, @units)
      @commodity.save
    end
  
    def handle_errors(exception)
      # Generic error handling for trade-related exceptions
      puts "Error processing trade: #{exception.message}"
      # Consider using a logging system like Sentry or Rollbar
    end
  
    # Add other shared methods that might be used by both buy and sell processes
  end
  