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

    home_api('/itunes/play')
    haml :wall_remote
  end

  get '/wall_remote/pause', auth: :user do
    @title = 'Soupstraw Wall Remote!'
    @no_navbar = true
    @refresh = 30.minutes

    home_api('/itunes/pause')
    haml :wall_remote
  end

end
