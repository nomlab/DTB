TOGGL_API_CLIENT = Toggl::Base.new(ApplicationSettings.toggl.token)
TOGGL_API_CLIENT = nil unless TOGGL_API_CLIENT.me(true)
