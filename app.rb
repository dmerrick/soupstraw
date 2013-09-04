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
    @string = "---------- 16:46 9/3/2013 ----------\nApproximate BTC mined: 0.01617622\nUSD rate (current avg.): $136.77\n------------------------------------\nProgress to positive ROI: 3.66%\nBTC left to positive ROI: 0.42542378\n------------------------------------\nApproximate USD earned: $2.21\n------------------------------------"
    haml :bitcoins
  end


  # start the server if ruby file executed directly
  run! if app_file == $0
end
