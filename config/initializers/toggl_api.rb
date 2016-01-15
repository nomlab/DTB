cli = Toggl::Base.new(ApplicationSettings.toggl.token)

begin
  cli.me(true)
  TOGGL_API_CLIENT = cli
rescue
  warn 'Warn: Your Toggl API is invalid. DTB will record work time by itself.'
  TOGGL_API_CLIENT = nil
end
