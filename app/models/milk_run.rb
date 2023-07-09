class MilkRun  < ApplicationRecord
    belongs_to :buy_commodity, class_name: 'Commodity', foreign_key: 'buy_commodity_id'


    def self.select_by_session(session_id)
        MilkRun.where(trade_session_id:session_id)
    end

end