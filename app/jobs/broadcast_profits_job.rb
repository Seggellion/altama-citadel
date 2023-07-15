class BroadcastProfitsJob < ApplicationJob
    queue_as :default
  
    def perform
      profits = MilkRun.group(:user_id).sum(:profit)
      ActionCable.server.broadcast("user_profits", profits: profits)
    end
  end
  