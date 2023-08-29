class AslController < ApplicationController
    before_action :set_task, only: %i[ show edit update destroy ]
    before_action :task_manager


def state_asl_message_next
    
    current_message = current_user.my_messages.find_by_id(params[:current_message])
    next_message = current_message.next_created
    sender =''
    if current_message
      sender = current_message.sender.id
    end
    #byebug
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
    task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "ASL")
    unless  task
      task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "Guildstone")
    end


    receiver_id = task.state.split('|')[0].split('-').last
    #receiver = User.find_by(id: @receiver_id)
    receiver = User.find_by(username: receiver_id)

    current_message = Message.find_by_id(params[:current_message])
    sender =''
   # if current_message
     # sender = current_message.sender.id
    #end
    #byebug
    previous_message = current_message.prev_created(receiver.id)
#byebug
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
    #
    #receiver = User.find_by(id: receiver_id)
   # receiver ||= User.find_by(username: receiver_id

   # @last_message = current_user.filtered_by_receiver(receiver.id).last
    # TODO: changed task_id to sender_id - will have to add in a way to check for tasks later
    @messages = current_user.my_messages.where(sender_id: sender).order(:id).last
    task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "ASL")
    @window_states =  []
    
    state_name = "message-#{sender}"
    if @messages
      last_message = "|#{@messages.id}"
      window_state_csv = task.state
      unless window_state_csv.nil?
        @window_states = window_state_csv.split(',')
      end  
      unless @window_states.include?(state_name  + last_message)
        @window_states = @window_states + Array[state_name + last_message]
      end
    else
      @window_states = @window_states + Array[state_name]
    end
    states_string = @window_states.join(',')

    task.update(state:states_string)

    @receiver_id = task.state.split('|')[0].split('-').last
    @receiver = User.find_by(id: @receiver_id)
    @receiver ||= User.find_by(username: @receiver_id)

    @last_message = current_user.filtered_by_receiver(@receiver.id).last

   
    redirect_to root_path
    byebug
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
    @window_states.push(state_name)
    #@window_states =  @window_states + state_name
    task.update(state: state_name)

    redirect_to root_url
  end

  def asl_read_message

    #receiver needs to be grabbed from state name
 
    task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "ASL")
    unless  task
      task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "Guildstone")
    end
    receiver_name = task.state.split('|')[0].split('-').last
    receiver = User.find_by(username: receiver_name)
    current_message = current_user.filtered_by_receiver(receiver.id).last
    #sender =''
    #if current_message
     # sender = current_message.sender.id
   # end

    previous_message = current_message.prev_created(receiver.id)

    byebug
    @window_states =  []
    state_name = task.state
    #curr_message = "|#{current_message.id}"
    #prev_message = "|#{previous_message.id}"
    window_state_csv = task.state
    unless window_state_csv.nil?
      @window_states = window_state_csv.split(',')
      message_states = window_state_csv.split('|')
    end  
    #unless @window_states.include?(state_name + prev_message)
     # @window_states = @window_states - Array[state_name + curr_message]
      #@window_states = @window_states + Array[state_name + prev_message] 
   # end 
    states_string = @window_states.join(',')   
    task.update(state:states_string)
    redirect_to(request.env['HTTP_REFERER'])
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

  def asl_add_contact
    
    task = @all_tasks.find_by(task_manager_id: @task_manager.id, name: "ASL")
    @window_states =  []
    state_name = "asl_add_contact"
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


  def send_message
    
    # Get the data from the request
    
    receiver_id = params[:receiver_id]
    asl_number = params[:asl_number]
    content = params[:content]
    
    # Check for valid data
    if asl_number.blank? || content.blank?
      render json: { status: 'error', message: 'Receiver ID or content missing.' }, status: :unprocessable_entity
      return
    end
  
    # Fetch the receiver
    receiver = User.find_by(asl_number: asl_number)
    receiver ||= User.find_by(username: receiver_id)
  
    # Check if the receiver exists
    unless receiver
      render json: { status: 'error', message: 'Receiver not found.' }, status: :not_found
      return
    end

    # Create the message
    message = Message.new(
      user_id: current_user.id,
      sender_id: current_user.id, # Assuming current_user is available here
      receiver_id: receiver.id,
      content: content
    )
    
    # Check if the message saves successfully
    if message.save
      # Broadcast the new message to the recipient
      message_content = "#{current_user.username}: #{message.content}"
      MessagesChannel.broadcast_to(receiver, message: message_content)
  
      # Return a successful response
      render json: { status: 'success', username: current_user.username, content: content }
    else
      render json: { status: 'error', message: 'Failed to send the message.' }, status: :internal_server_error
    end
  end

  
  def send_friend_request
    
    friend = User.find_by(asl_number: params[:asl_number])
    friend ||= User.find_by(username: params[:username])



    task = current_user.task_manager.tasks.last
    if friend
      existing_friendship = Friendship.find_by(user_id: friend.id, friend_id: current_user.id)
      
      if !existing_friendship.nil?

  
        Friendship.create(
            user_id: current_user.id,
            friend_id: friend.id,
            status: "accepted",
            group: params[:group]
        )
        
        current_user.messages.find_by(sender_id:friend.id, subject: "Friend Request").destroy
        existing_friendship.update(status:"accepted")
        message_text = 'added to contact list'
 
        task.update(state:"")
        
      else

        Friendship.create(
            user_id: current_user.id,
            friend_id: friend.id,
            status: "pending",
            group: params[:group]
        )

        # Assuming friend is the user receiving the friend request
        message_content = "#{current_user.username} sent you a friend request!"
        message = Message.create!(
          user_id: friend.id, 
          sender_id: current_user.id,
          receiver_id: friend.id,
          content: message_content,
          subject: "Friend Request"
        )
        task.update(state:"")
        message_text = 'Friend request sent!'
        # Broadcast the notification
    #    ActionCable.server.broadcast("friend_request_for_#{friend.id}", { message: message_content })
# Broadcast the new message to the recipient
Rails.logger.info "Broadcasting message to friend_request_for_#{friend.id}"
MessagesChannel.broadcast_to(friend, message: render_message(message))
      end
        render json: { status: 'success', message: message_text }

        # (rest of the code remains unchanged)
    else
        render json: { message: "User not found!" }, status: :not_found
    end
    redirect_to root_path
end


  private

  def render_message(message)
    task = @all_tasks.find_by_name("ASL").name
    ApplicationController.renderer.render(partial: 'asl/user-contact', locals: { message: message, task: task })
  end

  def new_message_params
    params.require(:message).permit(:sender_id, :user_id, content)
  end
end