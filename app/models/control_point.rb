class ControlPoint < ApplicationRecord
    belongs_to :event
    has_one :team

def iscaptured?
control_point = ControlPoint.find_by_id(self.id)
    if control_point.capture_team_id.present?
        p "captured"
    end
end

def percent_captured(totalSeconds)
    last_record_time = EventRecord.where(control_point_id:self.id).last
    
    if last_record_time
        percent_captured = ((DateTime.now.utc - last_record_time.start_time) / totalSeconds) * 100
        if percent_captured <= 100
            percent_captured
        else
            p 100
        end
    else
        false
    end
end

def conquesting
    last_record_time = EventRecord.where(control_point_id:self.id).last
    if last_record_time && !self.capture_team_id
        return true
    end
end

def capture_team
    capture_team = Team.find_by_id(self.capture_team_id)
    if capture_team
    capture_team.team_name
    end
end

def team_color
    capture_team = Team.find_by_id(self.capture_team_id)
    # last_record = EventRecord.where(control_point_id:self.id).last
    
    if capture_team && capture_team.team_color
        capture_team.team_color
    elsif capture_team 
    p 'blue'
    end

end

def team_record_color
    last_record = EventRecord.where(control_point_id:self.id).last
    if last_record && last_record.team.team_color
        last_record.team.team_color
    elsif last_record
    p 'blue'
    end

end


    def last_record_time
        last_record = EventRecord.where(control_point_id:self.id).last
        if last_record && last_record.action != 'stop'
            last_record.start_time
        else
            false
        end
    end
end
