class UserProfitsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "user_profits"
  end

  def unsubscribed
    stop_all_streams
  end
end
