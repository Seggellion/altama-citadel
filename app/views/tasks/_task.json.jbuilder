json.extract! task, :id, :name, :author, :icon, :created_at, :updated_at
json.url task_url(task, format: :json)
