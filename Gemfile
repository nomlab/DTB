source 'http://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5.2'

# rack based asset packaging system
gem 'sprockets-rails'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'

# Use SCSS for stylesheets
gem 'sass-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby if RUBY_PLATFORM.match(/linux/)

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use Toggl API v8
gem 'toggl_api', github: 'okada-takuya/toggl_api'

gem 'jquery-minicolors-rails'

gem 'bootstrap3-datetimepicker-rails'

gem 'awesome_nested_set'

gem 'chosen-rails'

# https://github.com/mbleigh/seed-fu
gem 'seed-fu'

# For pagenation
# https://github.com/amatsuda/kaminari
gem 'kaminari'

# https://github.com/twbs/bootstrap-sass
gem 'bootstrap-sass'

# https://github.com/bokmann/font-awesome-rails
gem 'font-awesome-rails'

gem 'thor'

# application settings
gem 'settingslogic'

# Show progress bar
gem 'nprogress-rails'

group :development do
  # For Profiling
  gem 'rack-mini-profiler'
  gem 'ruby-prof'
  gem 'rbtrace'
  gem 'rack-contrib'

  # For detecting N + 1 problem
  gem 'bullet'

  # Static Ruby code analizer
  gem 'rubocop', require: false
end

# For test
group :development, :test do
  # test framework
  gem 'rspec-rails'

  # Generate instance simply
  gem 'factory_girl_rails'

  # Generate dummy data
  gem 'faker'
end

group :test do
  # Check test coverage
  gem 'coveralls', require: false
end
