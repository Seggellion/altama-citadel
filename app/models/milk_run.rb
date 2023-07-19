class MilkRun  < ApplicationRecord
    belongs_to :buy_commodity, class_name: 'Commodity', foreign_key: 'buy_commodity_id'
    belongs_to :user
    belongs_to :trade_session
    after_commit :broadcast_profits, on: [:create, :update]

    def self.select_by_session(session_id)
        MilkRun.where(trade_session_id:session_id)
    end


    
    def grouped_profits
        MilkRun.group(:user_id).sum(:profit)
    end
    

    private
  
    def broadcast_profits
        BroadcastTradeRunProfitsJob.perform_later(self.trade_session_id)
    end

end