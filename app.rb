require 'rubygems'
require 'open-uri'
require 'json'
require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/activerecord'
require 'sqlite3'
require 'haml'
require 'newrelic_rpm'

require './config/environments'
require './models/user'


class Soupstraw < Sinatra::Base

  require './helpers/render_partial'
  require './helpers/bitcoin'

  # short sessions for bitcoin page
  use Rack::Session::Pool, :expire_after => 60

  set :database_file, "config/database.yml"

  configure :production do
    db = URI.parse(ENV['DATABASE_URL'] || 'postgres:///localhost/mydb')

    ActiveRecord::Base.establish_connection(
      :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
      :host     => db.host,
      :username => db.user,
      :password => db.password,
      :database => db.path[1..-1],
      :encoding => 'utf8'
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

  register do
    def auth (type)
      condition do
        redirect "/log_in" unless send("is_#{type}?")
      end
    end
  end
  register Sinatra::ActiveRecordExtension

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

  get "/protected", :auth => :user do
    haml :'users/show'
  end

  get "/cheat" do
    session[:user_id] = 1
    "you fuckin' cheater"
  end

  get '/users/:id' do
    @user = User.find(params[:id])
    haml :'users/show'
  end

  post "/log_in" do
    session[:user_id] = User.authenticate(params).id
    haml :'users/show'
  end

  get "/log_in" do
    haml :log_in
  end

  get "/logout" do
    session[:user_id] = nil
  end

  # start the server if ruby file executed directly
  run! if app_file == $0

end
