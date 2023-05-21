class TradeRun < ApplicationRecord

    def commodity
        unless self.commodity_id.nil?            
            Commodity.find_by_id(self.commodity_id)
        end
    end

    def commodity_name
        self.commodity.name
    end

def splits
    TradeRunSplit.where(traderun_id: self.id)
end


end