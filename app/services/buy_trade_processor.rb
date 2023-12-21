class BuyTradeProcessor
    def initialize(buy_commodity, sell_commodity, twitch_channel, total_units, to_user, starbits)
      @buy_commodity = buy_commodity
      @sell_commodity = sell_commodity
      @twitch_channel = twitch_channel
      @total_units = total_units
      @to_user = to_user
      @starbits = starbits
    end
  
    def process      

      return { capital: 'commodity_not_found' }.to_json unless @buy_commodity.present?
      return { capital: '30000 ERROR' }.to_json unless @sell_commodity.present?

      if @buy_commodity.inventory > 0
        process_valid_trade
      elsif @buy_commodity.inventory.zero?
        { capital: 'insufficient_inventory' }.to_json
      else
        { capital: 'invalid' }.to_json
      end
    end
  
    private
  
    def process_valid_trade
      actual_removed = calculate_actual_removed
      capital = @buy_commodity.sell.to_i * actual_removed
  
      if capital <= @starbits
        execute_trade(actual_removed, capital)
      else
        { capital: 'insufficient_funds' }.to_json
      end
    end
  
    def calculate_actual_removed
      [ @buy_commodity.maxInventory, @total_units].min.tap do |units|
        [ @buy_commodity.inventory, units].min
      end
    end
  
    def execute_trade(actual_removed, capital)
      update_inventory(actual_removed)
      manage_existing_runs
      create_new_run(actual_removed)
  
      { capital: capital }.to_json
    end
  
    def update_inventory(units)
      if @buy_commodity.inventory >= units
        @buy_commodity.decrement!(:inventory, units)
      else
        # Handle the scenario when inventory is insufficient.
        # This could involve raising an error, adjusting the transaction, or other business logic.
        raise "Insufficient inventory to complete the transaction."
      end
      @buy_commodity.save
    end
  
    def manage_existing_runs
      
      existing_run = StarBitizenRun.where(user_id: @to_user.id, twitch_channel: @twitch_channel,  profit: 0)
      existing_run.destroy_all if existing_run.present?
    end
  
    def create_new_run(units)
      StarBitizenRun.create!(
        twitch_channel: @twitch_channel, 
        commodity_id: @buy_commodity.id, 
        user_id: @to_user.id, 
        profit: 0, 
        scu: units
      )
    rescue => e
      handle_transaction_error(e)
    end
  
    def handle_transaction_error(exception)
      Sentry.capture_exception(exception, extra: { 
        twitch_channel: @twitch_channel, 
        user_id: @to_user.id 
      })
      raise exception
    end
  end
  