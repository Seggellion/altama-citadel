class TradeRun < ApplicationRecord
belongs_to :trade_session

    def commodity
        unless self.commodity_id.nil?            
            Commodity.find_by_id(self.commodity_id)
        end
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


end