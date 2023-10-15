class StarBitizenController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :parse_json_request, :validate_secret_guid

  def buy_trade    
    setup_trade_variables        
    records_exist = @buy_commodity.present? && @sell_commodity.present?
    
    response = handle_buy_trade(records_exist, @buy_commodity, @twitch_channel, @total_units, @to_user, @starbits)
    
    render json: response
  rescue => e
    logger.error "Exception in buy_trade: #{e.message}"
    render json: { capital: '30000 ERROR' }, status: 500
  end

  
  def sell_trade
    @sell_commodity = find_sell_commodity
    records_exist = @sell_commodity.present?
    @current_run = find_current_run
    response = handle_sell_trade(records_exist, @current_run, @sell_commodity)
    render json: response
  end

  private

  def handle_buy_trade(records_exist, buy_commodity, twitch_channel, total_units, to_user, starbits)
    response = {capital:  '30000 ERROR'}
    
    if records_exist && buy_commodity.inventory > 0
        actual_removed = [buy_commodity.maxInventory, total_units].min
        actual_removed = [buy_commodity.inventory, actual_removed].min

        # Now calculate the capital
        capital = buy_commodity.sell.to_i * actual_removed
        
        if capital <= starbits
            buy_commodity_inventory = buy_commodity.decrement!(:inventory, actual_removed)    
            buy_commodity.save
            total_profit = 0
            existing_run = StarBitizenRun.find_by(user_id: to_user.id, profit:0)

            existing_run = StarBitizenRun.where(user_id: to_user.id, profit:0)

            if existing_run.present? 
                existing_run.destroy_all
            end

            begin
              StarBitizenRun.create!(twitch_channel: twitch_channel, commodity_id: buy_commodity.id, user_id: to_user.id, profit: total_profit, scu: actual_removed)
            rescue => e
              Sentry.capture_exception(e, extra: { twitch_channel: twitch_channel, user_id: to_user.id })
              raise e
            end
            
            #StarBitizenRun.create(twitch_channel: twitch_channel, commodity_id: buy_commodity.id, user_id: to_user.id, profit: total_profit, scu: actual_removed)          
            response = {capital:  capital }
        else
            response = {capital:  'insufficient_funds' }
        end
    elsif records_exist &&  buy_commodity.inventory == 0
        response = {capital:  'insufficient_inventory' }
    else
        response = {capital:  'invalid' }
    end
    puts "outputting failure"
    return response.to_json
end


  def handle_sell_trade(records_exist, current_run, sell_commodity)
    response = {total_sold: '30000 ERROR'}
    
    if records_exist && current_run
      total_units = current_run.scu
      buy_commodity = current_run.commodity
      capital = buy_commodity.sell * total_units
      total_profit = (sell_commodity.buy.to_i * total_units) - capital
      total_sold = sell_commodity.buy.to_i * total_units
      
      current_run.update(profit: total_profit)
      response = { total_sold: total_sold }
    else
      response = { total_sold: 'invalid' }
    end
    response.to_json
  end
  

  def parse_json_request
    @json_request ||= JSON.parse(request.body.read)
  end

  def validate_secret_guid
    @secretguid = ENV['STARBITIZEN_EXCHANGE']
    received_guid = @json_request["secretguid"]

    unless @secretguid == received_guid
      render json: { error: 'Invalid secret guid' }, status: :unauthorized
      return
    end
  end

  def setup_trade_variables
    @commodity_name = @json_request["commodity"]
    @starbits = @json_request["starbits"].to_i
    @trade_locations = Location.where(trade_terminal:true)
    player_name = @json_request["player_name"]    
    @twitch_channel = @json_request["twitch_channel"]
    from_location_string = @json_request["from_location"]
    from_location = @trade_locations.search_for(from_location_string).first&.name
    
    to_location_string = @json_request["to_location"]
    to_location = @trade_locations.search_for(to_location_string).first&.name
    
    @sell_commodity = Commodity.where(name: @commodity_name, location: to_location).where('buy > ?', 0).first

    @buy_commodity = Commodity.where(name: @commodity_name, location: from_location).where('sell > ?', 0).first
    
    @total_units = @json_request["total_units"].to_i
    
    @to_user = fetch_or_create_user(player_name)    
    
  end

  def find_sell_commodity    
    commodity_name = @json_request["commodity"]
    to_location = @json_request["to_location"]
    sell_search_query = "#{commodity_name} #{to_location}"
    #Commodity.where(active: true).search_by_name_and_location(sell_search_query).where('buy > ?', 0).first

    Commodity.where(active: true)
    .search_by_exact_name(sell_search_query[:name])
    .search_by_location(sell_search_query[:location])
    .where('buy > ?', 0).first

  end

  def find_current_run
    player_name = @json_request["player_name"]
    
    to_user_id = User.where("username ILIKE ?", player_name).first.id
    @twitch_channel = @json_request["twitch_channel"].to_i
    StarBitizenRun.find_by(user_id: to_user_id, twitch_channel: @twitch_channel, profit: 0)
    
  end

  def fetch_or_create_user(player_name)
    user = User.where("username ILIKE ?", player_name).first_or_initialize do |new_user|
      new_user.username = player_name
      new_user.password = SecureRandom.hex(10)
      new_user.provider = 'StarBitizen'
    end    
    user.save! if user.new_record?
    user
  end  

  
end
