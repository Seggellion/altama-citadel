class BroadcastMilkRunProfitsJob < ApplicationJob
    queue_as :default
  
    def perform(trade_session_id)
      profits = MilkRun.where(trade_session_id: trade_session_id).joins(:user).group('users.username').sum(:profit)
  
      ActionCable.server.broadcast("milkrun_profits_channel_#{trade_session_id}", profits)
  
      Rails.logger.info "Broadcasted MilkRun data: #{profits}"
    end
  end
  