require 'rubygems'
require 'sinatra/base'
require 'sinatra/twitter-bootstrap'
require 'haml'

class SinatraBootstrap < Sinatra::Base
  require './helpers/render_partial'

  register Sinatra::Twitter::Bootstrap::Assets

  # ?
  #enable :inline_templates

  get '/' do
    haml :index
  end

  get '/btc' do
    `/Users/dmerrick/bin/bitcoin_earnings.rb`
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
