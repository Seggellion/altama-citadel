class Event < ApplicationRecord
    has_many :control_points

        def capture_limit_seconds
            capture_limit = Event.find_by_id(self.id).capture_limit
            capture_limit * 60
        end

        def series_title
            
           EventSeries.find_by_id(self.event_series_id).title

        end

        def joined?(user)
            current_user = User.find_by_id(user)
            event = Event.find_by_id(self.id)
            
            return true if EventUser.find_by(user_id: current_user.id, event_id: event.id)
        end
end
