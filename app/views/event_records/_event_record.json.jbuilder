json.extract! event_record, :id, :event_type, :event_id, :start_time, :end_time, :duration, :team_id, :control_point, :points, :rank_placement, :created_at, :updated_at
json.url event_record_url(event_record, format: :json)
