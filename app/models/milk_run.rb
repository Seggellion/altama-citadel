class MilkRun  < ApplicationRecord
    belongs_to :buy_commodity, class_name: 'Commodity', foreign_key: 'buy_commodity_id'
    belongs_to :user
    belongs_to :trade_session

    def self.select_by_session(session_id)
        MilkRun.where(trade_session_id:session_id)
    end

end