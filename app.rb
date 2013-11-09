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
require 'chartkick'
require 'groupdate'

# include everything in lib and everything in models
Dir["./lib/sinatra/*.rb"].each { |file| require file }
Dir["./models/*.rb"].each      { |file| require file }


class Soupstraw < Sinatra::Base

  require './helpers/render_partial'

  enable :sessions
  enable :logging

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

    def is_dana?
      is_user? && @user.id == 1
    end

    def h(text)
      Rack::Utils.escape_html(text)
    end
  end

  # enable partials
  helpers RenderPartial
  # enable redirections with little messages
  helpers Sinatra::RedirectWithFlash

  # ------------------------------------------------------------

  register do
    # this redirects users to the log in page if they're not a user
    def auth(type)
      condition do
        unless send("is_#{type}?")
          redirect '/log_in' + "?path=#{request.path}", :warning => 'You must be logged in to view this page.'
        end
      end
    end
  end

  # enable activrecord
  register Sinatra::ActiveRecordExtension
  # enable litte messages
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
    @stats = BitcoinStatsSnapshot.nonzero.last
    haml :'bitcoin/earnings'
  end

  # this is a work in progress that only dana really needs to see
  get '/stats', :auth => :dana do
    @title = 'Bitcoin Stats'
    haml :'bitcoin/stats'
  end

  # to make the btc mined chart load faster
  get '/btc_mined.json' do
    content_type :json
    # format the data for chartkick
    BitcoinStatsSnapshot.nonzero.group_by_hour(:created_at).maximum(:btc_mined).to_json
  end

  # to make the btc mined chart load faster
  get '/total_earned.json' do
    content_type :json
    most_recent_snapshot = BitcoinStatsSnapshot.last
    # format the data for chartkick
    graph_data = BitcoinStatsSnapshot.nonzero.group_by_day(:created_at).maximum('btc_mined * usd_value')
    graph_data[most_recent_snapshot.created_at.to_s] = most_recent_snapshot.total_earned
    graph_data.to_json
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

  # temporary trick to let other people log in
  get "/cheat/:path" do
    session[:user_id] = 1
    redirect params[:path], :danger => 'you cheater :p'
  end

  get '/users/:id' do
    @user = User.find(params[:id])
    haml :'users/show'
  end

  post "/log_in" do
    session[:user_id] = User.authenticate(params).id
    redirect back
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
