class UserProfitsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "user_profits_channel"
    Rails.logger.info "Successfully subscribed to UserProfitsChannel"
  end
  def unsubscribed
    stop_all_streams
  end
end
