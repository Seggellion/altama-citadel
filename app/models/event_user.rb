class EventUser < ApplicationRecord
    belongs_to :user
    belongs_to :event
    validates :user_id, uniqueness: { scope: :event_id, message: 'has already joined this event' }
    
    def usership
        Usership.find(self.usership_id)
    end

    def must_join_all?
        event = Event.find_by_id(self.event.id)
        if event.event_series_id.present?
            event_series = EventSeries.find_by_id(event.event_series_id)
            return true if event_series.must_join_all
        else
            p 'No series'
        end
    end
end
