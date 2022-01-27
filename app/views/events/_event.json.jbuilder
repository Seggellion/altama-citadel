json.extract! event, :id, :title, :owner_id, :start_date, :tournament_id, :description, :event_type, :created_at, :updated_at
json.url event_url(event, format: :json)
