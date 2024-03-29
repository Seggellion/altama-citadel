class DesktopController < ApplicationController
# before_action :authenticate_user!
before_action :require_login
before_action :task_manager,  except: [:bsod, :bootup]


def index  
  redirect_to bsod_path && return if @task_manager.nil?
  if @all_tasks
    @windowed_tasks = @all_tasks.where(view:'window')
    @fullscreen_tasks = @all_tasks.where(view:'fullscreen')   
    @current_task = @fullscreen_tasks.first.present? ? @fullscreen_tasks.first : @windowed_tasks.first.present? ? @windowed_tasks.first : nil
    @window3_tasks = @all_tasks.where(view: "slim")
  end  

  
if !@current_task.nil? and @current_task.name.downcase.include? "location"    
  if @current_task.state and @current_task.state.downcase.include? "subitem"
    location = Location.find_by_id(@current_task.state.downcase.split(',')[0].split('-')[-1])    
    if location.present? and location.parent != nil
      @locations = Location.where(parent:location.parent)
    else
      @locations = Location.where(parent:location.id)
    end    
  else    
    @locations = Location.where(location_type:1)
  end
  @location = Location.new
end

  @local_users = User.all.order('last_login DESC NULLS LAST', rsi_verify: :desc)
  @all_users = @local_users + DiscordUser.all + RsiUser.all  
  
  @root_users = User.all.order('last_login DESC NULLS LAST', rsi_verify: :desc)
  @twitch_users = User.where("provider ILIKE ?", "twitch")
  @all_locations = Location.all.order(name: :asc)
  @all_locations_parent_grouped = @all_locations.order(parent: :asc)
  @tradeports = Location.where(trade_terminal: true).order('parent ASC')
  @all_traderuns = TradeRun.all.order(created_at: :desc)
    if !@current_task.nil? and @current_task.state
      @viewing_traderuns = TradeRun.where(trade_session_id: @current_task.state.split("-").last).order(created_at: :desc)
    end
  location_list = Article.where(article_type: "location")
  location_ids = location_list.map { |location| location[:location_id] }
  
  @all_locations_without_dossier  = @all_locations.where.not(id: location_ids)
  @all_events = Event.all
  @altama_users = User.where.not(org_title: [nil, ""])
  dossier_list = Article.where(article_type: "dossier")
  dossier_ids = dossier_list.map { |user| user[:reference_id] }
  @altama_users_without_dossier = @altama_users.where.not(id: dossier_ids)

  @milk_runs = MilkRun.all
  
  @milk_run =  MilkRun.new
  @bots = Bot.all.order(created_at: :asc)
  @discord_users =  DiscordUser.all.order(role: :desc)
  @rsi_users = RsiUser.all.order(title: :asc, username: :asc)
  @ships = Ship.all.order(model: :asc)
  @cargo_ships = Ship.where("scu > ?", 1).order(model: :asc)
  @ship = Ship.new
  @selected_ship = Ship.find_by_id(params[:ship_id])
  @manufacturers = Manufacturer.all
  @components = ShipComponent.all
  @manufacturer = Manufacturer.new
  @article = Article.new
  @commodity = Commodity.new
  @reward  = Reward.new
  @all_rewards = Reward.all
  @all_commodities = Commodity.all.order(name: :asc)
  @active_commodities = @all_commodities.where(active:true)
  @readable_commodities = Commodity.select(:name).distinct.order(name: :asc)
  @user_manager = Task.find_by(task_manager_id: @task_manager.id, name: "User Manager")
  @hash =  [*('a'..'z'),*('0'..'9')].shuffle[0,8].join
  @myfleetships = current_user.userships.where(show_information:true)
  @traderun_new = TradeRun.new
  @tradesession_new = TradeSession.new
  @all_trade_sessions = TradeSession.all.order(session_date: :desc)
  @timeline_events = Event.where(event_type:nil)
  @traderun_split_new = TradeRunSplit.new
  @profit_scu_traderuns = []
  @asl_users = User.where.not(asl_number: nil).where.not(id: @current_user.id)
  current_user.desktop
    @commodity_stubs = CommodityStub.all.order(created_at: :desc)
    # @leaderboard_data = User.left_joins(:commodity_stubs).group("users.id").order("COUNT(commodity_stubs.id) DESC").select("users.id as user_id", "users.username", "COUNT(commodity_stubs.id) as total_commodities")

    @leaderboard_data_true = User.left_joins(:commodity_stubs)
    .where(commodity_stubs: { flagged: true })
    .group("users.id")
    .order("COUNT(commodity_stubs.id) DESC")
    .select("users.id as user_id", "users.username", "COUNT(commodity_stubs.id) as total_commodities")

    @leaderboard_data_false = User.left_joins(:commodity_stubs)
    .where(commodity_stubs: { flagged: [false, nil] })
    .group("users.id")
    .order("COUNT(commodity_stubs.id) DESC")
    .select("users.id as user_id", "users.username", "COUNT(commodity_stubs.id) as total_commodities")

    @leaderboard_data_false = @leaderboard_data_false.reject { |user| user.total_commodities.zero? }
    @leaderboard_data_true = @leaderboard_data_true.reject { |user| user.total_commodities.zero? }
    @friendships_by_group = current_user.friendships.includes(:friend).group_by(&:group)

# Discord::Notifier.message('Discord Notifier Webhook Notification')
end

def ship_view_switch

end

def display_preferences
  
    unless @all_tasks.find_by(name:'Display Preferences').present?
  
      if @current_user.save
      @task =  Task.create(name: 'Display Preferences',task_manager_id: @task_manager.id, view: 'slim')
  
      end
    end  
    redirect_to root_path
  
end

def rsi_user_list
  users = RsiUser.write
RsiUser.match


  task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "User Manager")
  task.update(state:"rsi_users")

redirect_to desktop_path
end
def discord_user_list
  users = DiscordUser.write
  redirect_to desktop_path
end

def bootup

        if @current_user
  TaskManager.find_or_create_by(user_id: @current_user.id)
        else
redirect_to bsod_path
        end

end

def bsod

end

  def users

    unless @all_tasks.find_by(name:'User Manager').present?
   
      @task =  Task.create(name: 'User Manager',task_manager_id: @task_manager.id, view: 'window')
    end  
    
      respond_to do |format|
        format.html { redirect_to desktop_path, notice: "location manager" }
        end
  end


end
