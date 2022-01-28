class ControlPoint < ApplicationRecord
    belongs_to :event

def iscaptured?
control_point = ControlPoint.find_by_id(self.id)
    if control_point.capture_team_id.present?
        p "captured"
    end
end

def capture_team
    capture_team = Team.find_by_id(self.capture_team_id)
    capture_team.team_name
end

    def last_record_time
        last_record_time = EventRecord.where(control_point_id:self.id).last
        if last_record_time
            last_record_time.start_time
        else
            false
        end
    end
end
