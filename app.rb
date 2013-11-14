#!/usr/bin/env ruby

require 'rubygems'
require 'open-uri'
require 'json'
require 'bundler'

# include all gems specified in the gemfile
Bundler.require(:default)
Bundler.require((ENV['RACK_ENV'] || 'development').to_sym)

# include everything in lib and everything in models
Dir['./lib/**/*.rb'].each  { |file| require file }
Dir['./helpers/*.rb'].each { |file| require file }
Dir['./models/*.rb'].each  { |file| require file }


class Soupstraw < Sinatra::Base

  enable :sessions
  enable :logging

  configure :development do
    use BetterErrors::Middleware
    # need to set in order to abbreviate filenames
    BetterErrors.application_root = File.expand_path('..', __FILE__)
  end

  # start the server if ruby file executed directly
  run! if app_file == $PROGRAM_NAME

  # ------------------------------------------------------------

  set :database_file, 'config/database.yml'

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
  # enable bitcoin methods
  helpers Bitcoin

  # ------------------------------------------------------------

  register do
    # this redirects users to the log in page if they're not a user
    def auth(type)
      condition do
        unless send("is_#{type}?")
          redirect '/log_in' + "?path=#{request.path}", warning: 'You must be logged in to view this page.'
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

  get '/?' do
    # redirect to the dual stats page
    redirect '/bitcoins/1+2'
  end

  get '/bitcoins/?' do
    @rig_id = request[:rig_id] || 1
    redirect "/bitcoins/#{@rig_id}"
  end

  # combine the total_earned data for two rigs
  # this allows the chart load to faster via AJAX
  get '/bitcoins/*+*/total_earned.json' do |id_a, id_b|
    content_type :json

    graph_a = MiningRig.find(id_a).average_earned_graph_data
    graph_b = MiningRig.find(id_b).average_earned_graph_data

    # this iterates over the graphed data for the first
    # rig, and adds to it the data from the second rig
    graph_data = graph_a.reduce({}) do |hash, key_and_value|
      date           = key_and_value.first
      total_earned_a = key_and_value.last
      total_earned_b = graph_b[date] || 0.0
      hash[date]     = total_earned_a + total_earned_b
      hash
    end

    graph_data.to_json
  end

  # matchs /bitcoins/1+2
  # (or another combination of rig_ids)
  get '/bitcoins/*+*' do |id_a, id_b|
    # get the last snapshots for both rigs
    snapshot_a = MiningRig.find(id_a).last_snapshot
    snapshot_b = MiningRig.find(id_b).last_snapshot

    @title = 'Bitcoin Earnings'
    @stats = snapshot_a + snapshot_b
    @graph_payload = "/bitcoins/#{id_a}+#{id_b}/total_earned.json"
    haml :'bitcoin/earnings'
  end

  # this allows the chart load to faster via AJAX
  get '/bitcoins/:rig_id/total_earned.json' do
    content_type :json

    rig_id = params[:rig_id]
    rig = MiningRig.find(rig_id)
    most_recent = rig.last_snapshot

    graph_data = rig.average_earned_graph_data
    graph_data[most_recent.created_at.to_s] = most_recent.total_earned
    graph_data.to_json
  end

  get '/bitcoins/:rig_id/last_snapshot.json' do
    rig = MiningRig.find(params[:rig_id])
    snapshot = rig.last_snapshot

    # list of attributes to include in the json
    #TODO: figure out how to do break_even(:usd) and break_even_progress(:usd)
    methods = %i(id btc_mined usd_value created_at btc_per_day usd_per_day total_earned break_even break_even_progress)
    methods.reduce({}) do |hash, method|
      hash[method] = snapshot.send(method)
      hash
    end.to_json
  end

  get '/bitcoins/:rig_id' do
    @rig_id = params[:rig_id] || 1
    rig = MiningRig.find(@rig_id)

    @title = 'Bitcoin Earnings'
    @stats = rig.last_snapshot
    @graph_payload = "/bitcoins/#{@rig_id}/total_earned.json"
    haml :'bitcoin/earnings'
  end

  # this is a work in progress that only dana really needs to see
  get '/stats', auth: :dana do
    @rig_id = request[:rig_id] || 1
    @title = 'Bitcoin Stats'
    haml :'bitcoin/stats'
  end

  # this allows the chart load to faster via AJAX
  get '/btc_mined.json' do
    content_type :json

    @rig_id = request[:rig_id] || 1
    rig = MiningRig.find(@rig_id)

    # format the data for chartkick
    rig.snapshots.group_by_hour(:created_at).maximum(:btc_mined).to_json
  end

  # temporary trick to let other people log in
  get '/cheat/:path' do
    session[:user_id] = 1
    redirect params[:path], danger: 'you cheater :p'
  end

  get '/users/:id' do
    @user = User.find(params[:id])
    haml :'users/show'
  end

  post '/log_in' do
    session[:user_id] = User.authenticate(params).id
    redirect back
  end

  get '/log_in' do
    haml :log_in
  end

  get '/log_out' do
    session[:user_id] = @user = nil
    flash.now[:info] = 'You are now logged out.'
    haml :log_in
  end

  get '/home' do
    @title = 'Soupstraw!'
    haml :index
  end

end
