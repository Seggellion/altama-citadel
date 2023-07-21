class StarBitizenRun < ApplicationRecord
    belongs_to :user
    has_one :commodity

end