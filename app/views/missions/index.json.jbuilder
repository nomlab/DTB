json.array!(@missions) do |mission|
  json.extract! mission, :id, :name, :description, :deadline, :status, :keyword, :parent_id
  json.url mission_url(mission, format: :json)
end
