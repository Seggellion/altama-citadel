class BroadcastProfitsJob < ApplicationJob
    queue_as :default
  
    def perform
      profits = MilkRun.joins(:user).group('users.username').sum(:profit)
      #ActionCable.server.broadcast("user_profits", profits: profits)
     # ActionCable.server.broadcast 'user_profits_channel', profits: grouped_profits


    ActionCable.server.broadcast("user_profits_channel", profits)
  
   #   ActionCable.server.broadcast 'user_profits_channel', profits: profits
      Rails.logger.info "Broadcasted data: #{profits}"
    end
  end
  