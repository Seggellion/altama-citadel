class TradeRunSplit < ApplicationRecord

def commodity_name
    Commodity.find_by_id(self.commodity_id).name
end

end