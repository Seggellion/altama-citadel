class MilkrunProfitsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "milkrun_profits_channel"
    Rails.logger.info "Successfully subscribed to MilkRunProfitsChannel"
  end
  def unsubscribed
    stop_all_streams
  end
end
