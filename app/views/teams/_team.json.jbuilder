json.extract! team, :id, :team_name, :owner_id, :description, :karma, :fame, :website, :created_at, :updated_at
json.url team_url(team, format: :json)
