class EventShip < ApplicationRecord
    belongs_to :usership
    belongs_to :event
end
