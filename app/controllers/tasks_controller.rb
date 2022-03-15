class TasksController < ApplicationController
  before_action :set_task, only: %i[ show edit update destroy ]

  # GET /tasks or /tasks.json
  def index
    @tasks = Task.all
  end

  # GET /tasks/1 or /tasks/1.json
  def show
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

  def start_bot
    
      token = ENV['GOOGLE_APPLICATION_CREDENTIALS'] 
      bot_cmd = Discordrb::Commands::CommandBot.new token: token, prefix: '!'
      bot_cmd.command(:update) do |event, *args|
        # This simply sends the bot's invite URL, without any specific permissions,
        # to the channel.
        # username = event.message.content.partition(':').last
        # uid = username[3..-1]
    
        data = event.message.content.split(',')
        uid = data[1]
        status = data[2].to_s
        #uid = uid.chomp('>')
        puts uid
        #user = await client.get_user_info(uid)
        user = bot_cmd.user(uid)
        message = %W{#{user.username}}
        user.pm('Hey ' + user.username + ' It looks like your status is now set to: ' + status )
        #await client.send_message(me, "Hello!")
    
        #event.bot.invite_url
      end
    
      bot_cmd.command(:exit, help_available: false) do |event|
        # This is a check that only allows a user with a specific ID to execute this command. Otherwise, everyone would be
        # able to shut your bot down whenever they wanted.
        
      
        bot.send_message(event.channel.id, 'Bot is shutting down')
        exit
      end
    
    #bot.users.fetch('Seggellion').then(dm => {
    #    dm.send('Hello World')
    #})
    
    # This method call has to be put at the end of your script, it is what makes the bot actually connect to Discord. If you
    # leave it out (try it!) the script will simply stop and the bot will not appear online.
    bot_cmd.run
    redirect_to desktop_path

  end

  def stop_bot
   # AltamaBot.stop
   binding.break
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
