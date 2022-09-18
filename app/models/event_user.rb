class EventUser < ApplicationRecord
    belongs_to :user
    belongs_to :event

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
