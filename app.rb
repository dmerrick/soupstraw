require 'rubygems'
require 'open-uri'
require 'json'
require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'haml'
require 'newrelic_rpm'

require './lib/sinatra/flash_style'
require './lib/sinatra/redirect_with_flash'
require './models/user'
require './models/bitcoin_stats_snapshot'


class Soupstraw < Sinatra::Base

  require './helpers/render_partial'
  require './helpers/bitcoin'

  # short sessions for bitcoin page
  #FIXME: this doesn't work with current authentication system
  use Rack::Session::Pool, :expire_after => 60

  #set :database_file, "config/database.yml"

  # shouldn't sinatra do this for me?
  configure :production, :development do
    env = settings.environment.to_s

    YAML::load(File.open('config/database.yml'))[env].each do |key, value|
      set key, value
    end

    #FIXME: this pollutes the settings namespace
    ActiveRecord::Base.establish_connection(
      adapter:  settings.adapter,
      host:     settings.host,
      database: settings.database,
      username: settings.username,
      password: settings.password
    )
  end

  helpers do
    def is_user?
      @user != nil
    end

    def h(text)
      Rack::Utils.escape_html(text)
    end
  end
  helpers RenderPartial, Bitcoin
  helpers Sinatra::RedirectWithFlash

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

  before do
    @user = User.find(session[:user_id]) if session[:user_id]
  end

  get '/' do
    @title = "Soupstraw!"
    haml :index
  end

  get '/bitcoins' do
    @title = "Bitcoin Earnings"
    @data_is_old = true if session[:total_mined]
    haml :bitcoins
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

  # start the server if ruby file executed directly
  run! if app_file == $0

end
