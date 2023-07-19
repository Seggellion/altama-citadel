class BroadcastMilkRunProfitsJob < ApplicationJob
    queue_as :default
  
    def perform(trade_session_id)
      profits = MilkRun.where(trade_session_id: trade_session_id).joins(:user).group('users.username').sum(:profit)
  
      channel_name = "milk_run_profits_channel_#{trade_session_id}"
      Rails.logger.info "Broadcasting to #{channel_name}"
      ActionCable.server.broadcast(channel_name, profits)
  
      
  
      Rails.logger.info "Broadcasted MilkRun data: #{profits}"
    end
  end
  