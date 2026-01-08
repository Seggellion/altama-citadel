class EventShip < ApplicationRecord
    belongs_to :usership
    belongs_to :event

    # Add these lines
    has_many :event_ship_crews, dependent: :destroy
    has_many :crew_members, through: :event_ship_crews, source: :user
    
    # Helper to check if ship has specific crew
    def staffed?
        event_ship_crews.any?
    end
end
