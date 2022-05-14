class Ship < ApplicationRecord
    belongs_to :manufacturer, optional: true
    has_one_attached :image_topdown

def expandedships(user) 
    
    Usership.where(ship_id: self.id, user_id: user.id )
end

end
