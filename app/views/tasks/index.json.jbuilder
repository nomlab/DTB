json.array!(@tasks) do |task|
  json.extract! task, :id, :name, :description, :deadline, :state_id, :keyword, :mission_id, :duration
  json.url task_url(task, format: :json)
end
