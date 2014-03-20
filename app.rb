#!/usr/bin/env ruby

require 'rubygems'
require 'open-uri'
require 'json'
require 'net/http'
require 'uri'
require 'bundler'

# include all gems specified in the gemfile
Bundler.require(:default)
Bundler.require((ENV['RACK_ENV'] || 'development').to_sym)

# include everything in lib and everything in models
Dir['./lib/**/*.rb'].each { |file| require file }
Dir['./app/models/*.rb'].each { |file| require file }


class Soupstraw < Sinatra::Base

  configure :development do
    use BetterErrors::Middleware
    # need to set in order to abbreviate filenames
    BetterErrors.application_root = File.expand_path('..', __FILE__)
  end

  # start the server if ruby file executed directly
  run! if app_file == $PROGRAM_NAME

  # ------------------------------------------------------------

  set :database_file, 'config/database.yml'
  set :settings_file, 'config/application.yml'
  set :views, Proc.new { File.join(root, 'app', 'views') }

  env = settings.environment.to_s

  # import settings from application.yml
  application_settings = {}
  YAML.load_file(File.open(settings.settings_file))[env].each do |key, value|
    application_settings[key.to_sym] = value
  end
  set :app, application_settings

  # import settings from database.yml
  database_settings = {}
  YAML.load_file(File.open(settings.database_file))[env].each do |key, value|
    database_settings[key.to_sym] = value
  end
  set :database, database_settings

  # set up activerecord connection
  ActiveRecord::Base.establish_connection(
    adapter:  settings.database[:adapter],
    host:     settings.database[:host],
    database: settings.database[:database],
    username: settings.database[:username],
    password: settings.database[:password]
  )

  # ------------------------------------------------------------

  register do
    # this redirects users to the log in page if they're not a user
    def auth(type)
      condition do
        unless send("is_#{type}?")
          redirect '/log_in', warning: 'You must be logged in to view this page.'
        end
      end
    end
  end

  # enable activrecord
  register Sinatra::ActiveRecordExtension
  # enable litte messages
  register Sinatra::Flash

  # ------------------------------------------------------------

  enable :logging

  # enable sessions
  use Rack::Session::Cookie, :expire_after => 90.days,
                             :secret => settings.app[:cookie_secret]

  # ensure the agent is started using Unicorn
  # this is needed when using Unicorn and preload_app is not set to true
  # c.p. https://docs.newrelic.com/docs/ruby/no-data-with-unicorn
  if defined?(Unicorn) && File.basename($0).start_with?('unicorn')
    ::NewRelic::Agent.manual_start()
    ::NewRelic::Agent.after_fork(force_reconnect: true)
  end

end

# include helpers and routes
require_relative 'app/helpers/init'
require_relative 'app/routes/init'
