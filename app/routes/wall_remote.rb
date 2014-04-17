class Soupstraw < Sinatra::Base

  get '/wall_remote', auth: :user do
    @title = 'Soupstraw Wall Remote!'
    @no_navbar = true
    @refresh = 30.minutes
    haml :wall_remote
  end

  get '/wall_remote/play', auth: :user do
    @title = 'Soupstraw Wall Remote!'
    @no_navbar = true
    @refresh = 30.minutes

    response = home_api('/itunes/play')
    flash.now[:info] = response.body
    haml :wall_remote
  end

  get '/wall_remote/pause', auth: :user do
    @title = 'Soupstraw Wall Remote!'
    @no_navbar = true
    @refresh = 30.minutes

    response = home_api('/itunes/pause')
    flash.now[:info] = response.body
    haml :wall_remote
  end

end
