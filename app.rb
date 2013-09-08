require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'
require 'haml'
require 'newrelic_rpm'
require 'open-uri'
require 'json'

class Soupstraw < Sinatra::Base

  require './helpers/render_partial'
  require './helpers/bitcoin'

  helpers RenderPartial, Bitcoin

  helpers do
    def h(text)
      Rack::Utils.escape_html(text)
    end
  end

  # short sessions for bitcoin page
  use Rack::Session::Pool, :expire_after => 60

  get '/' do
    @title = "Soupstraw!"
    haml :index
  end

  get '/bitcoins' do
    @title = "Bitcoin Earnings"
    @data_is_old = true if session[:total_mined]
    haml :bitcoins
  end

  # start the server if ruby file executed directly
  run! if app_file == $0

end
