class TasksController < ApplicationController
  before_action :set_task, only: %i[ show edit update destroy ]
before_action :task_manager
  # GET /tasks or /tasks.json
  def index
    @tasks = Task.all
  end

  # GET /tasks/1 or /tasks/1.json
  def show
  end

  def killall
    @all_tasks.destroy_all
    respond_to do |format|
      format.html { redirect_to desktop_path, notice: "Closed all tasks" }
      end
  end

def close_position_window
  window = params[:window]
  window_state_csv = @all_tasks.where(name: 'Guildstone').first.state
  @window_states =  []
  unless window_state_csv.nil?
    @window_states = window_state_csv.split(',')
  end  
  if @window_states.include?(window)
    @window_states = @window_states - Array(window)
  end
  states_string = @window_states.join(',')
  @all_tasks.where(name: 'Guildstone').first.update(state:states_string)
respond_to do |format|
  format.html { redirect_to guildstone_path(0), notice: "opened position" }
  end

end

def close_user_position_window
  window = params[:window]
  window_state_csv = @all_tasks.where(name: 'Guildstone').first.state
  @window_states =  []

  unless window_state_csv.nil?
    @window_states = window_state_csv.split(',')
  end  
  if @window_states.include?(window)
    @window_states = @window_states - Array(window)
  end
  states_string = @window_states.join(',')
  @all_tasks.where(name: 'Guildstone').first.update(state:states_string)
  respond_to do |format|
    format.html { redirect_to guildstone_path(0), notice: "opened position" }
    end
end

def close_rules_window
  window = params[:window]
  window_state_csv = @all_tasks.where(name: 'Guildstone').first.state
  @window_states =  []

  unless window_state_csv.nil?
    @window_states = window_state_csv.split(',')
  end  
  if @window_states.include?(window)
    @window_states = @window_states - Array(window)
  end
  states_string = @window_states.join(',')
  @all_tasks.where(name: 'Guildstone').first.update(state:states_string)
  respond_to do |format|
    format.html { redirect_to guildstone_path(0), notice: "opened rules" }
    end
end

def close_state_window
  window = params[:window]
  task = @all_tasks.find_by_id(params[:task])
  unless task.state.nil?
    @window_states = task.state.split(',')
  end  
  if @window_states.include?(window)
    @window_states = @window_states - Array(window)
  end
  states_string = @window_states.join(',')
  task.update(state:states_string)
  respond_to do |format|
    format.html { redirect_to desktop_path, notice: "closed window" }
    end
end

def start_rfa_manager

  unless @all_tasks.find_by(name:'RFA Manager').present?
  @task =  Task.create(name: 'RFA Manager',task_manager_id: @task_manager.id, view: 'full')
  end  
  respond_to do |format|
  format.html { redirect_to rfas_path, notice: "location manager" }
  end
end

def start_ship_manager

unless @all_tasks.find_by(name:'Ship Manager').present?
  @task =  Task.create(name: 'Ship Manager',task_manager_id: @task_manager.id, view: 'window')
  end  
  respond_to do |format|
  format.html { redirect_to desktop_path, notice: "task started" }
  end

end


def start_location_manager

  unless @all_tasks.find_by(name:'Location Manager').present?
  @task =  Task.create(name: 'Location Manager',task_manager_id: @task_manager.id, view: 'window')
  end  
  respond_to do |format|
    format.html { redirect_to desktop_path, notice: "location manager" }
    end
end

def state_location_wizard
  task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "Location Manager")
  @window_states =  []
  state_name = "#{params[:state]},"
  window_state_csv = task.state
  unless window_state_csv.nil?
    @window_states = window_state_csv.split(',')
    unless @window_states.include?(state_name)
      @window_states = @window_states + Array[state_name]
    end
  else    
    @window_states = Array[state_name]
  end  
  states_string = @window_states.join(',')
  task.update(state:states_string)
  respond_to do |format|
    format.html { redirect_to desktop_path, notice: "location manager" }
    end
end


def state_location_edit
  task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "Location Manager")
    
  state_name = "#{params[:state]},"
  window_state_csv = task.state
  unless window_state_csv.nil?
    @window_states = window_state_csv.split(',')
    unless @window_states.include?(state_name)
      @window_states = @window_states + Array[state_name]
    end
  else    
    @window_states = Array[state_name]
  end  
  states_string = @window_states.join(',')
  task.update(state:states_string)
  respond_to do |format|
    format.html { redirect_to desktop_path, notice: "location manager" }
    end
end



def start_guildstone
  unless @all_tasks.find_by(name:'Guildstone').present?
    @task =  Task.create(name: 'Guildstone',task_manager_id: @task_manager.id, view: 'full')
  end
  respond_to do |format|
    format.html { redirect_to guildstone_path(0), notice: "opened position" }
    end

end

  def state_positions

    task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "Guildstone")
    @window_states =  []
    state_name = "#{params[:position]},"
    window_state_csv = task.state
    
    unless window_state_csv.nil?
      @window_states = window_state_csv.split(',')
    end  
    unless @window_states.include?(state_name)
      @window_states = @window_states + Array[state_name]
    end
    states_string = @window_states.join(',')
    task.update(state:states_string)
    
    respond_to do |format|
    format.html { redirect_to guildstone_path(0), notice: "opened position" }
    end
  end

  def state_user_positions
    @user_position_histories = UserPositionHistory.all
    @my_user_position_histories = UserPositionHistory.where(user_id: current_user.id)
    task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "Guildstone")
    @window_states =  []
    state_name = "UserPositions"
    window_state_csv = task.state
    
    unless window_state_csv.nil?
      @window_states = window_state_csv.split(',')
      
    end  
    unless @window_states.include?(state_name)
      @window_states = @window_states + Array[state_name]
    end
    states_string = @window_states.join(',')
    task.update(state:states_string)
    
    respond_to do |format|
    format.html { redirect_to guildstone_path(0), notice: "opened all positions list" }
    end
  end

  def state_rules
    @rules = Rule.all
    task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "Guildstone")
    @window_states =  []
    state_name = "Rules"
    window_state_csv = task.state
    
    unless window_state_csv.nil?
      @window_states = window_state_csv.split(',')
      
    end  
    unless @window_states.include?(state_name)
      @window_states = @window_states + Array[state_name]
    end
    states_string = @window_states.join(',')
    task.update(state:states_string)
    
    respond_to do |format|
    format.html { redirect_to guildstone_path(0), notice: "opened all rules list" }
    end
  end

  def state_all_users
    task_manager = TaskManager.find_by(user_id: current_user)
    task = @all_tasks.find_by(task_manager_id: task_manager.id, name: "User Manager")
    task.update(state:"all_users")

    respond_to do |format|
    format.html { redirect_to desktop_path, notice: "All users" }
    end
  end

  def state_root_users
    task_manager = TaskManager.find_by(user_id: current_user)
    task = @all_tasks.find_by(task_manager_id: task_manager.id, name: "User Manager")
    task.update(state:"root_users")
    
    respond_to do |format|
    format.html { redirect_to desktop_path, notice: "Root users" }
    end
  end

  def state_discord_users
    task_manager = TaskManager.find_by(user_id: current_user)
    task = @all_tasks.find_by(task_manager_id: task_manager.id, name: "User Manager")
    task.update(state:"discord_users")
    
    respond_to do |format|
    format.html { redirect_to desktop_path, notice: "Discord users" }
    end
  end

  def properties
    task_manager = TaskManager.find_by(user_id: current_user)
   @task =  Task.new(name: 'System Properties',task_manager_id: task_manager.id, view: 'window')
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

  def profile

    unless @all_tasks.find_by(name:'User profile').present?
      @task =  Task.create(name: 'User profile',task_manager_id: @task_manager.id, view: 'window')
    end
    respond_to do |format|
      format.html { redirect_to desktop_path, notice: "Task started." }
      end

  end

  def rsi_activate
    task_manager = TaskManager.find_by(user_id: current_user)
    @task =  Task.new(name: 'RSI Activate',task_manager_id: task_manager.id, view: 'window')
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
  

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks or /tasks.json
  def create
    @task = Task.new(task_params)

    respond_to do |format|
      if @task.save
        format.html { redirect_to @task, notice: "Task was successfully created." }
        format.json { render :show, status: :created, location: @task }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1 or /tasks/1.json
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to @task, notice: "Task was successfully updated." }
        format.json { render :show, status: :ok, location: @task }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1 or /tasks/1.json
  def destroy

    @task.destroy
    respond_to do |format|
      format.html { redirect_to desktop_path, notice: "Task closed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def task_params
      params.require(:task).permit(:name, :author, :icon)
    end
end
