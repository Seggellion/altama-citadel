class FriendRequestChannel < ApplicationCable::Channel
    def subscribed
      stream_from "friend_request_for_#{current_user.id}"
    end
  
    def receive(data)
        # Fetch the user to whom the friend request is being sent
        requested_user = User.find_by(id: data["requested_user_id"])
      
        # Create the friend request (assuming you have a FriendRequest model or similar)
        friend_request = current_user.friend_requests.new(requested_user: requested_user)
      
        if friend_request.save
          # Notify the recipient
          ActionCable.server.broadcast "friend_request_for_#{requested_user.id}", { 
            type: 'NEW_FRIEND_REQUEST', 
            from_user_id: current_user.id,
            from_user_name: current_user.username 
          }
        else
          # Handle errors, e.g., broadcast a failure message or log the error
        end
      end

      def unsubscribed
        # Any cleanup needed when channel is unsubscribed
      end

  end