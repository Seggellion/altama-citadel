class Event < ApplicationRecord
    has_many :control_points
    has_many :event_users, :dependent => :destroy
    has_many :event_ships, :dependent => :destroy

        def capture_limit_seconds
            capture_limit = Event.find_by_id(self.id).capture_limit
            capture_limit * 60
        end

        def series_title
            
           EventSeries.find_by_id(self.event_series_id).title

        end

        def self.timeline_events(year)
            year = year + 2010
            if year >= 2942
                year = year - 930
                date_beginning = Date.new(year,1,1) 
                date_ending = Date.new(year,12,31)
                start_date = date_beginning.to_date.beginning_of_day
                end_date = date_ending.to_date.end_of_day
                
                
                records = Event.where(event_type:nil).order(start_date: :asc)
                records = records.where(:created_at => start_date..end_date)
                
            else
                records = []
            end

            records
   
        end

def toggle_open
    if self.open.nil? || self.open == false
        self.update!(open:true)
    else
        self.update!(open:false)
    end
end

        def self.totalYears
            date_beginning = DateTime.new(2010,3,01)
            
            date_end = Event.all.order(start_date: :desc).last.start_date
            
            total_date = ((date_end.year + 931 ) - date_beginning.year)


        end

        def filteredFleet(user)
            
            return false unless keyword = self.keyword_required
            userships =    Usership.where(user_id:user.id, show_information:true)
            userships.select { |item| item.fid[0..1].to_s.include?(keyword)}
            
        end

        def joined?(user)
            current_user = User.find_by_id(user)
            event = Event.find_by_id(self.id)
            
            return true if EventUser.find_by(user_id: current_user.id, event_id: event.id)
        end
end
