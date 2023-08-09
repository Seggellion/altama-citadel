class MilkRunsController < ApplicationController
  before_action :set_milk_run_params, only: [:create]
  OUT_OF_FAMILY_THRESHOLD = 6.5

  def new
    @milk_run = MilkRun.new
    @commodities_for_sell = Commodity.joins(milk_runs: :user)
                                  .where.not(milk_runs: { sell_commodity_scu: 0, sell_commodity_id: nil })
                                  .select('commodities.*, users.username')
    @locations_for_sell = []
  end

  def profits
    render json: MilkRun.joins(:user).group('users.username').sum(:profit)
  end

  def show
    redirect_to root_path
  end

  def create
    case @milk_run_params[:form_type]
    when "buy"
      handle_buy_commodity
    when "sell"
      handle_sell_commodity
    end
    redirect_to @milk_run_params[:public] ? request.original_url : root_path
  end

  def destroy
    milk_run = MilkRun.find_by_id(params[:format])
    milk_run.destroy
    redirect_to root_path
  end

  private

  def set_milk_run_params
    @milk_run_params = params[:milk_run]
    @trade_session_id = @milk_run_params[:trade_session_id]
    @buy_commodity_id = @milk_run_params[:buy_commodity_id]
    @milk_run_username = @milk_run_params[:user_name]
    @milk_run_user_id = @milk_run_params[:user_id]
    @milk_run_public_username = @milk_run_params[:public_user_name]
  end

  def handle_buy_commodity
    return if @milk_run_username&.empty?
    ship_scu = find_ship_scu
    user = find_user
    existing_milkrun = find_existing_milkrun(user.id)
    
    create_milk_run_and_update_buy_commodity(user, ship_scu) unless existing_milkrun
  end

  def handle_sell_commodity
    commodity_user_id = @current_user ? @current_user.id : find_user.id
    current_milkrun = find_current_milkrun(commodity_user_id)
    
    process_sell_commodity(current_milkrun, commodity_user_id) if current_milkrun
  end

  def find_ship_scu
    Ship.find(@milk_run_params[:ship_id])&.scu
  end

  def find_user
    if @milk_run_username
      fetch_or_create_user(@milk_run_username)
    else

      if @milk_run_params[:public_user_name]
        username =  @milk_run_public_username
      else
        username = User.find_by_id(@milk_run_params[:user_id]).username
      end
      
      fetch_or_create_user(username)
    end
    
  end
  
  def fetch_or_create_user(player_name)    
    user = User.where("username ILIKE ?", player_name).first_or_initialize do |new_user|
      new_user.username = player_name
      new_user.password = SecureRandom.hex(10)
      new_user.provider = 'Trade123'
    end    
    user.save! if user.new_record?
    user
  end

  def find_existing_milkrun(user_id)
    MilkRun.find_by(buy_commodity_id: @buy_commodity_id, sell_commodity_id: nil, user_id: user_id)
  end

  def find_current_milkrun(commodity_user_id)
    MilkRun.find_by(trade_session_id: @trade_session_id, buy_commodity_id: @buy_commodity_id, sell_commodity_id: nil,  user_id: commodity_user_id)
  end

  def find_commodity_user_id(current_milkrun)
    @current_user ? @current_user.id : current_milkrun.user_id
  end

  def process_sell_commodity(current_milkrun, commodity_user_id)
    sell_commodity = Commodity.find_by_id(@milk_run_params[:sell_commodity_id])
    sell_location = JSON.parse(@milk_run_params[:sell_location])["name"].split('| ')[1]              
    used_scu = MilkRun.where(trade_session_id: @trade_session_id, user_id: commodity_user_id, sell_commodity_id:nil).sum(:buy_commodity_scu)
    buy_total = current_milkrun.buy_commodity_scu * current_milkrun.buy_commodity_price
    sell_total = @milk_run_params[:sell_commodity_scu].to_i * @milk_run_params[:sell_commodity_price].to_i
    profit = sell_total - buy_total
  
    percent_change = ((@milk_run_params[:sell_commodity_price].to_f - sell_commodity.buy) / sell_commodity.buy) * 100                            
    
    if out_of_family?(@milk_run_params[:sell_commodity_price], sell_commodity.buy) && current_user&.user_type != 0
      CommodityStub.create!(user_id: current_milkrun.user_id, commodity_id: sell_commodity.id, buy_price: @milk_run_params[:sell_commodity_price], flagged: true)
      current_milkrun.user.take_karma(1000)
      if current_milkrun.user.karma < -5000
        current_milkrun.user.update(user_type:9001)
      end
    else
      sell_commodity.update(buy: @milk_run_params[:sell_commodity_price], sell:0, updated_at: Time.now)
      current_milkrun.user.give_karma(200)
      current_milkrun.user.give_fame(200)
      CommodityStub.create!(user_id: current_milkrun.user_id, commodity_id: sell_commodity.id, buy_price: @milk_run_params[:sell_commodity_price])
      if @milk_run_params[:sell_commodity_scu].to_i < current_milkrun.buy_commodity_scu
        update_milkrun_for_partial_sell(current_milkrun, sell_commodity, sell_location, used_scu, sell_total, buy_total)
      else
        update_milkrun_for_full_sell(current_milkrun, sell_commodity, sell_location, used_scu, profit)
      end
    end
  end
  

  def update_milkrun_for_partial_sell(current_milkrun, sell_commodity, sell_location, used_scu, sell_total, buy_total)
    buy_total = @milk_run_params[:sell_commodity_scu].to_i * current_milkrun.buy_commodity_price
    profit = sell_total - buy_total
    MilkRun.create(
      buy_commodity_id: current_milkrun.buy_commodity_id,
      buy_commodity_scu:@milk_run_params[:sell_commodity_scu].to_i,
      buy_commodity_price:current_milkrun.buy_commodity_price,
      buy_location:current_milkrun.buy_location,
      usership_id: current_milkrun.usership_id,
      user_id: current_milkrun.user_id,
      trade_session_id:  current_milkrun.trade_session_id,
      sell_commodity_id: sell_commodity.id,
      sell_commodity_scu: @milk_run_params[:sell_commodity_scu].to_i,
      commodity_name: current_milkrun.commodity_name,
      sell_commodity_price: @milk_run_params[:sell_commodity_price].to_i, 
      sell_location: sell_location,    
      profit: profit, 
      used_scu: @milk_run_params[:sell_commodity_scu].to_i,
    )

    current_milkrun.update!(              
      buy_commodity_scu: current_milkrun.buy_commodity_scu - @milk_run_params[:sell_commodity_scu].to_i, 
      used_scu: used_scu,               
      updated_at: Time.now
    )
  end

  def update_milkrun_for_full_sell(current_milkrun, sell_commodity, sell_location, used_scu, profit)
    
    current_milkrun.update!(
      sell_commodity_id: sell_commodity.id,
      sell_commodity_scu: @milk_run_params[:sell_commodity_scu].to_i,
      sell_commodity_price: @milk_run_params[:sell_commodity_price].to_i, 
      sell_location: sell_location,          
      used_scu: used_scu, 
      profit: profit, 
      updated_at: Time.now
    )
  end

  def create_milk_run_and_update_buy_commodity(user, ship_scu)
    buy_commodity = Commodity.find_by_id(@buy_commodity_id)
    current_user = User.find_by_username(session[:username])
    if buy_commodity
      percent_change = ((@milk_run_params["buy_commodity_price"].to_f - buy_commodity.sell) / buy_commodity.sell) * 100
      out_of_family = percent_change.abs >= 6.5
  
      if out_of_family?(@milk_run_params["buy_commodity_price"], buy_commodity.sell) && current_user&.user_type != 0
        CommodityStub.create!(user_id: user.id, commodity_id: buy_commodity.id, buy_price: @milk_run_params["buy_commodity_price"], flagged: true)
        current_user.take_karma(1000)
        if current_user.karma < -5000
          current_user.update(user_type:9001)
        end
      else
        buy_commodity.update(sell: @milk_run_params["buy_commodity_price"], buy: 0, updated_at: Time.now)
        
        MilkRun.create!(
          user_id: user.id, 
          usership_id: @milk_run_params[:trade_session_id], 
          trade_session_id: @trade_session_id, 
          commodity_name: @milk_run_params[:commodity_name], 
          buy_commodity_id: @buy_commodity_id,
          buy_commodity_scu: @milk_run_params["buy_commodity_scu"],
          buy_commodity_price: @milk_run_params["buy_commodity_price"],
          buy_location: @milk_run_params["buy_location"],      
          max_scu: ship_scu, 
          used_scu: ship_scu,             
          updated_at: Time.now
        )

        
          unless current_user
            current_user = user
          end
          
          current_user.give_karma(200)
          current_user.give_fame(200)

        CommodityStub.create!(user_id: user.id, commodity_id: buy_commodity.id, buy_price: @milk_run_params["buy_commodity_price"])
      end
    end
  end
  

  def out_of_family?(price, base_price)    
    
    percent_change = (price.to_f - base_price) / base_price * 100
    percent_change.abs >= OUT_OF_FAMILY_THRESHOLD
  end

end
