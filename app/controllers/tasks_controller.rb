class TasksController < ApplicationController
  before_action :set_task, only: %i[ show edit update destroy ]

  # GET /tasks or /tasks.json
  def index
    @tasks = Task.all
  end

  # GET /tasks/1 or /tasks/1.json
  def show
  end

  def state_positions
    task_manager = TaskManager.find_by(user_id: current_user)
    task = Task.find_by(task_manager_id: task_manager.id, name: "Guildstone")
    
    state_name = "position #{params[:position]}"
    task.update(state:state_name)
    
    respond_to do |format|
    format.html { redirect_to desktop_path, notice: "Root users" }
    end
  end

  def state_all_users
    task_manager = TaskManager.find_by(user_id: current_user)
    task = Task.find_by(task_manager_id: task_manager.id, name: "User Manager")
    task.update(state:"all_users")

    respond_to do |format|
    format.html { redirect_to desktop_path, notice: "All users" }
    end
  end

  def state_root_users
    task_manager = TaskManager.find_by(user_id: current_user)
    task = Task.find_by(task_manager_id: task_manager.id, name: "User Manager")
    task.update(state:"root_users")
    
    respond_to do |format|
    format.html { redirect_to desktop_path, notice: "Root users" }
    end
  end

  def state_discord_users
    task_manager = TaskManager.find_by(user_id: current_user)
    task = Task.find_by(task_manager_id: task_manager.id, name: "User Manager")
    task.update(state:"discord_users")
    
    respond_to do |format|
    format.html { redirect_to desktop_path, notice: "Discord users" }
    end
  end

  def properties
    task_manager = TaskManager.find_by(user_id: current_user)
   @task =  Task.new(name: 'System Properties',task_manager_id: task_manager.id)
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
    task_manager = TaskManager.find_by(user_id: current_user)
    @task =  Task.new(name: 'User profile',task_manager_id: task_manager.id)
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

  def rsi_activate
    task_manager = TaskManager.find_by(user_id: current_user)
    @task =  Task.new(name: 'RSI Activate',task_manager_id: task_manager.id)
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
