# This file is used by Rack-based servers to start the application.

# To profile code
# require 'ruby-prof'
# require 'rack/contrib/profiler'
# use Rack::Profiler, :printer => :graph_html

require ::File.expand_path('../config/environment',  __FILE__)
run Rails.application
