json.array!(@unified_histories) do |unified_history|
  json.extract! unified_history, :id, :path, :title, :type, :r_path, :start_time, :end_time
  json.url unified_history_url(unified_history, format: :json)
end
