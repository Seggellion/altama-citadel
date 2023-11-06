class StarBitizenRun < ApplicationRecord
    belongs_to :user
    belongs_to :commodity


   # def commodity
   #     Commodity.find_by_id(self.commodity_id)
   # end

end