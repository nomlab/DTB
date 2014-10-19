json.array!(@time_entries) do |time_entry|
  json.extract! time_entry, :id, :name, :keyword, :comment, :start_time, :end_time, :toggl_time_entry_id, :task_id
  json.url time_entry_url(time_entry, format: :json)
end
