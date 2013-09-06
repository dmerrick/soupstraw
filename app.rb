require 'rubygems'
require 'sinatra/base'
require 'haml'
require 'open-uri'
require 'json'

class Soupstraw < Sinatra::Base

  require './helpers/render_partial'
  require './helpers/bitcoin'

  helpers RenderPartial, Bitcoin

  # short sessions for bitcoin page
  use Rack::Session::Pool, :expire_after => 60

  get '/' do
    @title = "Soupstraw!"
    haml :index
  end

  get '/bitcoins' do
    @title = "Bitcoin Earnings"
    haml :bitcoins
  end

  # start the server if ruby file executed directly
  run! if app_file == $0

end
