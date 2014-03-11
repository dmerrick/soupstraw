# load DSL and setup stages
require 'capistrano/setup'

# includes default deployment tasks
require 'capistrano/deploy'

# includes rbenv support
require 'capistrano/rbenv'

# includes bundler tasks
require 'capistrano/bundler'

# enable OSX notifications
require 'capistrano-nc/nc'

# enable newrelic notifications
require 'capistrano/newrelic'

# enable datadog integration
require 'capistrano/datadog'
require 'yaml'
set :datadog_api_key, YAML::load(File.open('config/application.yml'))['development']['datadog_key']

#TODO: implement this
# https://github.com/cramerdev/capistrano-chef
#require 'capistrano/chef'

# includes migration tasks
#TODO: get migrations working
#require 'capistrano/rails/migrations'

# loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }
