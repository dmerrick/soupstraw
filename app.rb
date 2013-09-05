require 'rubygems'
require 'sinatra/base'
require 'haml'

class Soupstraw < Sinatra::Base
  require './helpers/render_partial'

  get '/' do
    @title = "Soupstraw!"
    haml :index
  end

  get '/bitcoins' do
    @title = "Bitcoin Earnings"
    #FIXME: this is fugly
    @command_output = `/Users/dmerrick/.rvm/rubies/ruby-2.0.0-p247/bin/ruby /Users/dmerrick/other_projects/bitcoin_earnings/bitcoin_earnings.rb`
    haml :bitcoins
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
