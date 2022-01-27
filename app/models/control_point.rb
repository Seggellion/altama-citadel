class ControlPoint < ApplicationRecord
    belongs_to :event

def iscaptured?
control_point = ControlPoint.find_by_id(self.id)
    if control_point.capture_team_id.present?
        p "captured"
    end
end

    def last_record_time
        last_record_time = EventRecord.find_by(control_point_id:self.id)
        if last_record_time
            last_record_time.start_time
        else
            false
        end
    end
end
