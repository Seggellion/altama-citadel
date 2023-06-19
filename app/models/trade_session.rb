class TradeSession < ApplicationRecord
    belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'


    def total_profit
        profit = TradeRun.where(trade_session_id: self.id).sum(:profit)
        profit.to_s(:delimited)
    end

    def total_scu
        TradeRun.where(trade_session_id: self.id).sum(:scu)
    end
end