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

def start_my_hangar
  unless @all_tasks.find_by(name:'My Hangar').present?
    @task =  Task.create(name: 'My Hangar',task_manager_id: @task_manager.id, view: 'fullscreen')
    end  

    respond_to do |format|
      format.html { redirect_to my_hangar_path, notice: "task started" }
    end
end

def state_ship_modal
  usership = params[:ship]

  #@messages = current_user.my_messages.where(task_id: sender).order(:created_at).last
  task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "My Hangar")

  @window_states =  []
  state_name = "modal-#{usership}"
 # last_message = "|#{@messages.id}"
  window_state_csv = task.state
  unless window_state_csv.nil?
    @window_states = window_state_csv.split(',')
  end  
  unless @window_states.include?(state_name)
    @window_states = @window_states + Array[state_name]
  end
  states_string = @window_states.join(',')

  task.update(state:states_string)


  redirect_to(request.env['HTTP_REFERER'])
end

def close_position_window
  window = params[:window]
  task_name = params[:window]
  
  #magic number
  task = @all_tasks.where(name: 'Guildstone').first

  window_state_csv = task.state
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

def clear_memos
  @task_manager = TaskManager.find_by(user_id: current_user)
  @all_tasks = Task.where(task_manager_id: @task_manager.id)
  @memos = @all_tasks.where.not(memo_type: [nil, ""])
  
  @memos.update_all(memo_text: nil, memo_type:nil)
  redirect_to root_path
end

def close_last_window
  @task_manager = TaskManager.find_by(user_id: current_user)
  @all_tasks = Task.where(task_manager_id: @task_manager.id)
  @all_tasks.last.destroy
  redirect_to root_path
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
  redirect_to(request.env['HTTP_REFERER'])
 # respond_to do |format|
 #   format.html { redirect_to desktop_path, notice: "closed window" }
 #   end
end

def start_shell
  unless @all_tasks.find_by(name:'Altama Shell').present?
    @task =  Task.create(name: 'Altama Shell',task_manager_id: @task_manager.id, view: 'window')
    end  

      redirect_to root_path
    
end

def start_codex
  unless @all_tasks.find_by(name:'Codex').present?
    @task =  Task.create(name: 'Codex',task_manager_id: @task_manager.id, view: 'fullscreen')
    end  
    respond_to do |format|
    format.html { redirect_to root_path, notice: "Loaded codex" }
    end
end

def start_bot_manager
  unless @all_tasks.find_by(name:'Altama_exe').present?
    @task =  Task.create(name: 'Altama_exe',task_manager_id: @task_manager.id, view: 'window')
    end  
    respond_to do |format|
    format.html { redirect_to root_path, notice: "Loaded Bot Manageer" }
    end
end

def start_rfa_manager
  unless @all_tasks.find_by(name:'RFA Manager').present?
  @task =  Task.create(name: 'RFA Manager',task_manager_id: @task_manager.id, view: 'fullscreen')
  end  
  respond_to do |format|
  format.html { redirect_to rfas_path, notice: "location manager" }
  end
end

def start_asl
  unless @all_tasks.find_by(name:'ASL').present?
    @task =  Task.create(name: 'ASL',task_manager_id: @task_manager.id, view: 'window')
    end  
    redirect_to(request.env['HTTP_REFERER'])
end

def filter_state

window = params[:filter_type]
task = @all_tasks.find_by_id(params[:task])

#@new_ships =  @myships.joins("INNER JOIN ships ON ships.manufacturer_id = manufacturers.id AND manufacturers.id = 1")
#@myships.joins(ships: :manufacturer).where('manufacturers.id' => 1)
@myships = Usership.where(user_id: current_user.id)
@myships = Usership.joins(ship: :manufacturer).where('manufacturers.id' => 1)

@myships.each do |thisship|
  puts(thisship.ship_name)
end
#@myships = Usership.joins(:ships).where(ships: {ship: Ship.where(manufacturer: Manufacturer.find_by(id: 1))})
binding.break


window_state_csv = task.state
unless window_state_csv.nil?
  @window_states = window_state_csv.split(',')
  message_states = window_state_csv.split('|')
end  
unless @window_states.include?(state_name + nxt_message)
  @window_states = @window_states - Array[state_name + curr_message]
  @window_states = @window_states + Array[state_name + nxt_message]
  
end


unless task.state.nil?
  @window_states = task.state.split(',')
end  
if @window_states.include?(window)
  @window_states = @window_states - Array(window)
end

states_string = @window_states.join(',')

task.update(state:states_string)
redirect_to(request.env['HTTP_REFERER'])
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

def state_location_mainitem
  task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "Location Manager")

  task.update(state:"")
  respond_to do |format|
    format.html { redirect_to desktop_path, notice: "location manager" }
    end
end

def state_location_subitem
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
    @task =  Task.create(name: 'Guildstone',task_manager_id: @task_manager.id, view: 'fullscreen')
  end
  
  respond_to do |format|
    @task = Task.last
    #@task.memo(memo_type: "error", memo_text:"Error! NOT! LOL")
    format.html { redirect_to guildstone_path(0), notice: "success" }

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

def state_modals
  state_name = ""
  if params[:department_id].present?
    state_name = "modal-#{params[:department_id]}"
    modal_type = "|department"
  elsif  params[:task_id].present?
    state_name = "modal-allposition"
    modal_type = ""
    #state_name = "modal-#{params[:task_id]}"
   # modal_type = "|allposition"
  end

  task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "Guildstone")
  @window_states =  []
  window_state_csv = task.state
  unless window_state_csv.nil?
    @window_states = window_state_csv.split(',')
    @window_states = window_state_csv.split('|')
  end  
  unless @window_states.include?(state_name + modal_type)
    @window_states = @window_states + Array[state_name + modal_type]      
  end    
  states_string = @window_states.join(',')    
  
  task.update(state:states_string)
  redirect_to(request.env['HTTP_REFERER'])
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

  def state_twitch_users
    task_manager = TaskManager.find_by(user_id: current_user)
    task = @all_tasks.find_by(task_manager_id: task_manager.id, name: "User Manager")
    task.update(state:"twitch_users")
    
    respond_to do |format|
    format.html { redirect_to desktop_path, notice: "Twitch users" }
    end
  end

  def state_asl_message_next
    
    current_message = current_user.my_messages.find_by_id(params[:current_message])
    #next_message = current_user.my_messages.next_created(current_message.created_at).first
    next_message = current_message.next_created
    sender =''
    if current_message
      sender = current_message.sender.id
    end
    task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "ASL")
    @window_states =  []
    state_name = "message-#{sender}"
    curr_message = "|#{current_message.id}"
    nxt_message = "|#{next_message.id}"
    window_state_csv = task.state
    unless window_state_csv.nil?
      @window_states = window_state_csv.split(',')
      message_states = window_state_csv.split('|')
    end  
    unless @window_states.include?(state_name + nxt_message)
      @window_states = @window_states - Array[state_name + curr_message]
      @window_states = @window_states + Array[state_name + nxt_message]      
    end    
    states_string = @window_states.join(',')    
    task.update(state:states_string)
    redirect_to(request.env['HTTP_REFERER'])
  end



  def state_asl_message_prev
    current_message = current_user.my_messages.find_by_id(params[:current_message])

    sender =''
    if current_message
      sender = current_message.sender.id
    end
    #previous_message = current_user.my_messages.previous_created(current_message.created_at).first
    previous_message = current_message.prev_created
    task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "ASL")
    unless  task
      task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "Guildstone")
    end
    @window_states =  []
    state_name = "message-#{sender}"
    curr_message = "|#{current_message.id}"
    prev_message = "|#{previous_message.id}"
    window_state_csv = task.state
    unless window_state_csv.nil?
      @window_states = window_state_csv.split(',')
      message_states = window_state_csv.split('|')
    end  
    unless @window_states.include?(state_name + prev_message)
      @window_states = @window_states - Array[state_name + curr_message]
      @window_states = @window_states + Array[state_name + prev_message]
      
    end
    
    states_string = @window_states.join(',')
    
    task.update(state:states_string)
    redirect_to(request.env['HTTP_REFERER'])
  end

  def state_asl_message
    sender = params[:sender]
    @messages = current_user.my_messages.where(task_id: sender).order(:created_at).last
    task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "ASL")
    @window_states =  []
    state_name = "message-#{sender}"
    last_message = "|#{@messages.id}"
    window_state_csv = task.state
    unless window_state_csv.nil?
      @window_states = window_state_csv.split(',')
    end  
    unless @window_states.include?(state_name  + last_message)
      @window_states = @window_states + Array[state_name + last_message]
    end
    states_string = @window_states.join(',')
  
    task.update(state:states_string)
    redirect_to(request.env['HTTP_REFERER'])
  end


  def state_discord_users
    
    task_manager = TaskManager.find_by(user_id: current_user)
    
    @widget = "https://discord.com/api/guilds/355082120034779136/widget.json"
   data_json = RestClient::Request.execute(
    method:  :get, 
    url:     @widget,
    payload: '{ "username"}',
    headers: { content_type: 'application/json', accept: 'application/json'}
  )


    bot = Discordrb::Commands::CommandBot.new token: "#{ENV['TOKEN']}", prefix: '!', intents: [:server_members]

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
        format.html { redirect_to desktop_path }
        #format.html { redirect_to desktop_path, notice: "Task started." }
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
      format.html { redirect_to desktop_path}
      end
  end

  def help
      unless @all_tasks.find_by(name:'Help').present?
        @task =  Task.create(name: 'Help',task_manager_id: @task_manager.id, view: 'window')
      end  
        respond_to do |format|
          format.html { redirect_to desktop_path, notice: "help started" }
        end
  end

  def rsi_activate
    task_manager = TaskManager.find_by(user_id: current_user)
    @task =  Task.new(name: 'RSI Activate',task_manager_id: task_manager.id, view: 'window')
    respond_to do |format|
     if @task.save
       format.html { redirect_to desktop_path }
       format.json { render :index, status: :created, task: @task }
     else
       format.html { render :index, status: :unprocessable_entity }
       format.json { render json: @task.errors, status: :unprocessable_entity }
     end
   end
  end
  
  def sync_altama
    rsi_user = RsiUser.find_by('lower(username) = ?', current_user.username.downcase)
  task =  Task.find_by(task_manager_id:@task_manager.id, name: "User profile")
    if rsi_user.nil?
      
      return
    end
  
    if current_user.update(org_title: rsi_user.title, user_type: RsiUser.org_user_type_match(rsi_user))
      
    else
      task.memo(memo_type: "error", memo_text:"Error: No user in Altama Database.")
    end
  end
  





  

  def taskbar_button
current_task = Task.find_by_id(params[:task])
@all_tasks.update_all(view: '')
    current_task.update(view:'fullscreen')
    
      redirect_to root_path
    
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
    if @task.name == "RFA Manager" && current_user.online_status == "rfa_online"
      current_user.update(online_status: nil)
      eligible_rfas = Rfa.where("status_id < ?", 2)
      if User.where(online_status:"rfa_online").empty?
        eligible_rfas.update_all(users_online:false)
      end
    end
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
