#!/usr/bin/env ruby

require 'rubygems'
require 'open-uri'
require 'json'
require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'haml'
require 'newrelic_rpm'

# include everything in lib and everything in models
Dir["./lib/sinatra/*.rb"].each { |file| require file }
Dir["./models/*.rb"].each      { |file| require file }


class Soupstraw < Sinatra::Base

  require './helpers/render_partial'

  # enable sessions
  use Rack::Session::Pool

  # start the server if ruby file executed directly
  run! if app_file == $0

  # ------------------------------------------------------------

  set :database_file, "config/database.yml"

  #FIXME: this pollutes the settings namespace
  env = settings.environment.to_s
  YAML::load(File.open(settings.database_file))[env].each do |key, value|
    set key, value
  end

  ActiveRecord::Base.establish_connection(
    adapter:  settings.adapter,
    host:     settings.host,
    database: settings.database,
    username: settings.username,
    password: settings.password
  )

  # ------------------------------------------------------------

  helpers do
    def is_user?
      @user != nil
    end

    def h(text)
      Rack::Utils.escape_html(text)
    end
  end
  helpers RenderPartial
  helpers Sinatra::RedirectWithFlash

  # ------------------------------------------------------------

  register do
    def auth (type)
      condition do
        unless send("is_#{type}?")
          redirect "/log_in", :warning => 'You must be logged in to view this page.'
        end
      end
    end
  end
  register Sinatra::ActiveRecordExtension
  register Sinatra::Flash

  # ------------------------------------------------------------

  before do
    @user = User.find(session[:user_id]) if session[:user_id]
  end

  get '/' do
    @title = 'Soupstraw!'
    haml :index
  end

  get '/bitcoins' do
    @title = 'Bitcoin Earnings'
    @stats = BitcoinStatsSnapshot.last
    haml :'bitcoin/earnings'
  end

  get '/stats' do
    @title = 'Bitcoin Stats'
    @stats = BitcoinStatsSnapshot.last
    haml :'bitcoin/stats'
  end

  # example json output
  get '/bitcoins.json' do
    content_type :json
    stats = {}
    BitcoinStatsSnapshot.all.inject(stats) do |stats_hash, snapshot|
      stats_hash[snapshot.created_at] = [snapshot.btc_mined, snapshot.usd_value]
      stats_hash
    end
    stats.to_json
  end

  get "/private", :auth => :user do
    haml :'users/show'
  end

  get "/cheat" do
    session[:user_id] = 1
    redirect "/", :danger => "you fuckin\' cheater"
  end

  get '/users/:id' do
    @user = User.find(params[:id])
    haml :'users/show'
  end

  post "/log_in" do
    session[:user_id] = User.authenticate(params).id
    redirect '/'
  end

  get "/log_in" do
    haml :log_in
  end

  get "/log_out" do
    session[:user_id] = @user = nil
    flash.now[:info] = "You are now logged out."
    haml :log_in
  end

end
