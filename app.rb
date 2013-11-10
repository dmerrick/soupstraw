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

  env = settings.environment.to_s
  database_settings = {}
  YAML::load(File.open(settings.database_file))[env].each do |key, value|
    database_settings[key.to_sym] = value
  end
  set :database, database_settings

  ActiveRecord::Base.establish_connection(
    adapter:  settings.database[:adapter],
    host:     settings.database[:host],
    database: settings.database[:database],
    username: settings.database[:username],
    password: settings.database[:password]
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
    @rig_id = request[:rig_id] || 1
    redirect "/bitcoins/#{@rig_id}"
  end

  get '/bitcoins/:rig_id' do
    @rig_id = params[:rig_id] || 1
    rig = MiningRig.find(@rig_id)

    @title = 'Bitcoin Earnings'
    @stats = rig.last_snapshot
    haml :'bitcoin/earnings'
  end

  # matchs /miners1+2
  # (or another combination of rig_ids)
  get '/miners*+*' do |id_a, id_b|
    # get the last snapshots for both rigs
    rig_a      = MiningRig.find(id_a)
    rig_b      = MiningRig.find(id_b)
    snapshot_a = rig_a.last_snapshot
    snapshot_b = rig_b.last_snapshot
    graph_a    = rig_a.average_earned_by_day
    graph_b    = rig_b.average_earned_by_day

    # this iterates over the graphed data for the first
    # rig, and adds to it the data from the second rig
    @graph_data = graph_a.inject({}) do |hash, point|
      date           = point.first
      total_earned_a = point.last
      total_earned_b = graph_b[date] || 0.0
      hash[date]     = total_earned_a + total_earned_b
      hash
    end

    @title = 'Bitcoin Earnings'
    @stats = snapshot_a + snapshot_b
    haml :'bitcoin/earnings'
  end

  # this is a work in progress that only dana really needs to see
  get '/stats', :auth => :dana do
    @rig_id = request[:rig_id] || 1
    @title = 'Bitcoin Stats'
    haml :'bitcoin/stats'
  end

  # to make the btc mined chart load faster
  get '/btc_mined.json' do
    content_type :json

    @rig_id = request[:rig_id] || 1
    rig = MiningRig.find(@rig_id)

    # format the data for chartkick
    rig.nonzero_snapshots.group_by_hour(:created_at).maximum(:btc_mined).to_json
  end

  # to make the btc mined chart load faster
  get '/total_earned.json' do
    content_type :json

    rig_id = request[:rig_id] || 1
    rig = MiningRig.find(rig_id)

    most_recent_snapshot = rig.last_snapshot

    # format the data for chartkick
    #TODO: if days_running is > 90, group_by_week
    graph_data = rig.average_earned_by_day
    graph_data[most_recent_snapshot.created_at.to_s] = most_recent_snapshot.total_earned
    graph_data.to_json
  end

  # example json output
  get '/bitcoins.json' do
    content_type :json

    @rig_id = request[:rig_id] || 1
    rig = MiningRig.find(@rig_id)

    stats = {}
    rig.nonzero_snapshots.inject(stats) do |stats_hash, snapshot|
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
