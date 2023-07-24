class AslController < ApplicationController
    before_action :set_task, only: %i[ show edit update destroy ]
    before_action :task_manager


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
    # TODO: changed task_id to sender_id - will have to add in a way to check for tasks later
    @messages = current_user.my_messages.where(sender_id: sender).order(:id).last
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
    redirect_to root_path
  end

  def state_asl_message_new
    sender = params[:sender]
    @users = User.all
    @new_message = params[:new_message]
    @message = Message.new
    current_message = @message
    task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "ASL")
    @window_states =  []
    state_name = "new_message"
    @window_states =  @window_states + state_name
    task.update(state: state_name)

    redirect_to root_url

  end

  def create_new_message
    #byebug
    @message = Message.create(new_message_params)
  end

  def asl_add_user
    task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "ASL")
    @window_states =  []
    state_name = "asl_add_user"
    window_state_csv = task.state
    unless window_state_csv.nil?
      @window_states = window_state_csv.split(',')
    end  
    unless @window_states.include?(state_name)
        @window_states = @window_states + Array[state_name]
    end
    states_string = @window_states.join(',')
    
    task.update(state:states_string)
    redirect_to root_path
  end

  private
  def new_message_params
    params.require(:message).permit(:sender_id, :user_id, content)
  end
end