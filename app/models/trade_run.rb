class TradeRun < ApplicationRecord
belongs_to :trade_session
belongs_to :user, primary_key: 'username', foreign_key: 'username'
after_commit :broadcast_profits, on: [:create, :update]

    def commodity
        unless self.commodity_id.nil?            
            Commodity.find_by_id(self.commodity_id)
        end
    end

    def payout
0
    end

    def commodity_name        
        if self.commodity.present?       
            self.commodity.name
        else
            "error"
        end        
    end

def splits
    TradeRunSplit.where(traderun_id: self.id)
end

def broadcast_profits
    BroadcastTradeRunProfitsJob.perform_later(self.trade_session_id)
  end

end