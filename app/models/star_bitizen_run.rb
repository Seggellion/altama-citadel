class StarBitizenRun < ApplicationRecord
    belongs_to :user


    def commodity
        Commodity.find_by_id(self.commodity_id)
    end

end