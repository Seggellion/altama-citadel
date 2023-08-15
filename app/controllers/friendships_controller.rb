class FriendshipsController < ApplicationController

    def create
      @friendship = current_user.friendships.build(friend_id: params[:friend_id], status: 'pending')
      
      if @friendship.save
        # Notify the other user, etc.
        
        friend = User.find(params[:friend_id])
# Inside the controller action or model callback where the Friendship is created:

# Assuming friend is the user receiving the friend request
message_content = "#{current_user.username} sent you a friend request!"
message = Message.create!(
  user_id: friend.id, 
  sender_id: current_user.id,
  receiver_id: friend.id,
  content: message_content,
  subject: "Friend Request"
)

# Broadcast the notification
ActionCable.server.broadcast("friend_request_for_#{friend.id}", message: message_content)

render json: { status: 'success', message: 'Friend request sent!' }

      else
        render json: { status: 'error', message: 'Error sending friend request.' }, status: 422

        redirect_to root_path, alert: 'Error sending friend request.'
      end
    end
  
    def update
      @friendship = Friendship.find(params[:id])
      if @friendship.update(friendship_params)
        redirect_to friends_path, notice: 'Friendship status updated!'
      else
        redirect_to friends_path, alert: 'Error updating friendship status.'
      end
    end
  
    def destroy
      @friendship = Friendship.find(params[:id])
      @friendship.destroy
      redirect_to friends_path, notice: 'Friendship removed!'
    end
  
    private
  
    def friendship_params
      params.require(:friendship).permit(:status)
    end
  end
  