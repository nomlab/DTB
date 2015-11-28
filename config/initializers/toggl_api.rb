TOGGL_API_CLIENT = Toggl::Base.new(YAML.load_file("config/toggl.yml")["toggl_api_token"])
