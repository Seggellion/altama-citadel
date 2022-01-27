class EventRecord < ApplicationRecord
belongs_to :team

    def control_point

control_point = ControlPoint.find_by_id(self.control_point_id)
 control_point.title
    end
end
