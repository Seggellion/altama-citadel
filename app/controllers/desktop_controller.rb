class DesktopController < ApplicationController
# before_action :authenticate_user!
before_action :require_login


def index
  @current_user = current_user
  task_manager = TaskManager.find_by(user_id: current_user)
  
  if task_manager.nil?
    
    redirect_to bsod_path
    return
    
  end
  @all_tasks = Task.where(task_manager_id: task_manager.id)
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
  @user_manager = Task.find_by(task_manager_id: task_manager.id, name: "User Manager")
  @hash =  [*('a'..'z'),*('0'..'9')].shuffle[0,8].join
  current_user.desktop
# Discord::Notifier.message('Discord Notifier Webhook Notification')
end

def ship_view_switch

end

def rsi_user_list
  users = RsiUser.write
  task_manager = TaskManager.find_by(user_id: current_user)
  task = Task.find_by(task_manager_id: task_manager.id, name: "User Manager")
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
 task_manager = TaskManager.find_by(user_id: current_user)
 
@task =  Task.new(name: 'User Manager',task_manager_id: task_manager.id)
 
 respond_to do |format|
    if @task.save
      format.html { redirect_to desktop_path, notice: "Task started." }
      format.json { render :index, status: :created, task: @task }
    else
      format.html { render :index, status: :unprocessable_entity }
      format.json { render json: @task.errors, status: :unprocessable_entity }
    end
  end
end


end
