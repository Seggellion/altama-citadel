class Event < ApplicationRecord
    has_many :control_points

        def capture_limit_seconds
            capture_limit = Event.find_by_id(self.id).capture_limit
            capture_limit * 60
        end

end
