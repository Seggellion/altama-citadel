class TradeRunSplit < ApplicationRecord


def commodity_name        
    commodity = Commodity.find_by_id(self.commodity_id)
    if commodity.present?       
        commodity.name
    else
         "error"
    end        
end


end