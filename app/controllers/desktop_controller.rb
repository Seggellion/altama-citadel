class DesktopController < ApplicationController
# before_action :authenticate_user!
before_action :require_login

def index
  @current_user = current_user
  task_manager = TaskManager.find_by(user_id: current_user)
  @all_tasks = Task.where(task_manager_id: task_manager.id)
  @root_users = User.all
  @rsi_users = RsiUser.all.order(title: :desc)
  @ships = Ship.all
  @ship = Ship.new
  @selected_ship = Ship.find_by_id(params[:ship_id])
  @manufacturers = Manufacturer.all
  @manufacturer = Manufacturer.new
  @locations = Location.all
  @location = Location.new
# Discord::Notifier.message('Discord Notifier Webhook Notification')
end

def ship_view_switch
binding.break
end

def rsi_user_list
  users = RsiUser.write
redirect_to desktop_path

end

def bootup

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
