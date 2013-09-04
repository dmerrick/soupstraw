require 'rubygems'
require 'sinatra/base'
require 'sinatra/twitter-bootstrap'
require 'haml'

class SinatraBootstrap < Sinatra::Base
  require './helpers/render_partial'

  register Sinatra::Twitter::Bootstrap::Assets

  get '/' do
    haml :index
  end

  get '/bitcoins' do
    @title = "Bitcoin Earnings"
    @string = `/Users/dmerrick/.rvm/rubies/ruby-2.0.0-p247/bin/ruby /Users/dmerrick/other_projects/bitcoin_earnings/bitcoin_earnings.rb`
    haml :bitcoins
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
