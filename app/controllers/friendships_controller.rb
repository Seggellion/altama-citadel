class FriendshipsController < ApplicationController

    def create
      @friendship = current_user.friendships.build(friend_id: params[:friend_id], status: 'pending')
      if @friendship.save
        # Notify the other user, etc.
        redirect_to friends_path, notice: 'Friend request sent!'
      else
        redirect_to users_path, alert: 'Error sending friend request.'
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
  