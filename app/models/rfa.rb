class Rfa < ApplicationRecord
    belongs_to :user
    has_one :usership
    has_many :rfa_products
    has_many :commodities, :through => :rfa_products
    accepts_nested_attributes_for :usership
    after_update_commit {broadcast_replace_to 'active_rfa', partial: '/rfas/status', locals: { active_rfa: self }}

#  after_update_commit do
 #   broadcast_append_to 'active_rfa'

  #  broadcast_replace_to 'active_rfa',
  #  partial: 'web/rfa-status',
  #  target: "#{dom_id(self.id)}_item",
  #  locals: { active_rfa: self }

   # broadcast_append_to [self, :active_rfa],
    # target: "rfa_#{id}_item", 
   #  partial: '/web/rfa-status'


    #broadcast_update_to [active_rfa, :status], target: self
    #broadcast_append_to [rfa, :status], target: self
   # broadcast_append_to "active_rfa"
    #broadcast_append_to [post, :comments], target: "#{dom_id(post)}_comments", partial: 'web/rfa-status'

 # end
    def commodity_total(commodity)
      rfa_product  =RfaProduct.find_by(commodity_id: commodity.id, rfa_id: self.id)
      if rfa_product
      RfaProduct.find_by(commodity_id: commodity.id, rfa_id: self.id).amount
      else
        0
      end
    end

def line_item_price(commodity)
  rfa_product  =RfaProduct.find_by(commodity_id: commodity.id, rfa_id: self.id)
  if rfa_product
  RfaProduct.find_by(commodity_id: commodity.id, rfa_id: self.id).selling_price
  else
    0
  end
end

def location_name
    location_name = Location.find_by_id(self.location_id)
    if location_name.present?
        location_name.name
    else
        p 'No name listed'
    end
end

def status
    case self.status_id
    when 0
      "Unassigned"
    when 1
      "In Progress"
    when 2
      "Pending"
    when 3
      "On Hold"
    when 4
      "Solved"
    end
end

def status_response 
  user = User.find_by_id(self.user_assigned_id)
  case self.status_id    
  when 0
  "Waiting response from Support Queue (current wait times: X hours), Join our discord for instant updates"
  when 1 
    "#{user.username} has accepted your issue, please add as a friend"
  when 2
    "#{user.username}  has arrived and awaiting rendezvous"
  when 3
    "Issue is currently on hold"
  when 4
    "Would you like to complete a review?"
  end
end

def aec

end

def total_charge
@all_products = RfaProduct.where(rfa_id: self.id).sum(:selling_price).ceil

end


def full_ship_name
if self.ship_id
  ship = Ship.find_by_id(self.ship_id)
  manufacturer = Manufacturer.find_by_id(ship.manufacturer_id)
  p ship.model  + ", " + manufacturer.name
else
  "No ship data"
end
end


def price(commodity)
  
  commodity_price = Commodity.find_by(name: commodity).price
  user_discounts = self.user.discounts * 0.01

  price = commodity_price - (commodity_price * user_discounts)
price.round(4) 
end 

def self.get_status(status_id)
    case status_id
    when 0
      "Unassigned"
    when 1
      "In Progress"
    when 2
      "Pending"
    when 3
      "On Hold"
    when 4
      "Solved"
    end
end

def ship_name
    ship_name = Ship.find_by_id(self.ship_id)
    if ship_name.present?
        ship_name.model
    else
        p 'No ship listed'
    end
end

    def self.all_tickets
        self.all.count
    end

    def self.open_tickets
      self.where.not(status_id:4).count
    end

    def self.solved_tickets
        self.where(status_id:4).count
    end

end
