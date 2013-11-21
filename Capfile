# load DSL and setup stages
require 'capistrano/setup'

# includes default deployment tasks
require 'capistrano/deploy'

# includes rbenv support
require 'capistrano/rbenv'

# includes bundler tasks
require 'capistrano/bundler'

# includes migration tasks
#TODO: get migrations working
#require 'capistrano/rails/migrations'

#TODO: maybe add this later?
#require 'new_relic/recipes'

# loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }
