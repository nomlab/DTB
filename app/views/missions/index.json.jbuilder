json.array!(@missions) do |mission|
  json.extract! mission, :id, :name, :description, :deadline, :state_id, :keyword, :parent_id
  json.url mission_url(mission, format: :json)
end
