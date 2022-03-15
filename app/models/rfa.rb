class Rfa < ApplicationRecord
    belongs_to :user
    
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
        self.where(status_id:1).count
    end

    def self.solved_tickets
        self.where(status_id:4).count
    end

end
