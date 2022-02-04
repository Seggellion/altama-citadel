class Team < ApplicationRecord
has_many :event_records, :dependent => :destroy
    after_destroy_commit {broadcast_remove_to "teams"}

def conquest_duration(event)
    all_records_sum = EventRecord.where(event_id: event.id, team_id: self.id).sum(:duration)
    all_records_sum
end

    def active_control_point(control_point)
        control_point = ControlPoint.find_by_id(control_point)
        
        last_record = EventRecord.where(control_point_id: control_point.id).last
        
        if last_record && last_record.team_id == self.id
            p "active"
        else
            p "inactive"
        end
    end
end
