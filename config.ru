# This file is used by Rack-based servers to start the application.

# To profile code
# To show profiling, add param["profile"] = process_time
if Rails.env.development?
  require 'ruby-prof'
  require 'rack/contrib/profiler'
  use Rack::Profiler, :printer => :graph_html
end

require ::File.expand_path('../config/environment',  __FILE__)
run Rails.application
