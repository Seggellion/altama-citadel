class DesktopController < ApplicationController
# before_action :authenticate_user!
before_action :require_login
before_action :task_manager


def index
  
  redirect_to bsod_path && return if @task_manager.nil?
if @all_tasks
  @windowed_tasks = @all_tasks.where(view:'window')
  @fullscreen_tasks = @all_tasks.where(view:'full')
end

  @all_users = User.all + DiscordUser.all + RsiUser.all
  @local_users = User.all
  @root_users = User.all.order(last_login: :desc)
  @discord_users =  DiscordUser.all.order(role: :desc)
  @rsi_users = RsiUser.all.order(title: :desc)
  @ships = Ship.all
  @ship = Ship.new
  @selected_ship = Ship.find_by_id(params[:ship_id])
  @manufacturers = Manufacturer.all
  @manufacturer = Manufacturer.new
  @locations = Location.all
  @location = Location.new
  @commodity = Commodity.new
  @reward  = Reward.new
  @all_rewards = Reward.all
  @all_commodities = Commodity.all  
  @user_manager = Task.find_by(task_manager_id: @task_manager.id, name: "User Manager")
  @hash =  [*('a'..'z'),*('0'..'9')].shuffle[0,8].join
  @myfleetships = current_user.userships.where(show_information:true)
  @all_events = Event.all
  @timeline_events = Event.where.not(event_type:1)
  current_user.desktop
# Discord::Notifier.message('Discord Notifier Webhook Notification')
end

def ship_view_switch

end

def rsi_user_list
  users = RsiUser.write
  task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "User Manager")
  task.update(state:"rsi_users")

redirect_to desktop_path
end
def discord_user_list
  users = DiscordUser.write
  redirect_to desktop_path
end

def bootup

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
