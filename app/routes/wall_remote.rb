class Soupstraw < Sinatra::Base

  get '/wall_remote', auth: :user do
    wall_remote_settings
    haml :wall_remote
  end

  get '/wall_remote/play', auth: :user do
    wall_remote_settings
    response = home_api('/itunes/play')
    haml :wall_remote
  end

  get '/wall_remote/pause', auth: :user do
    wall_remote_settings
    response = home_api('/itunes/pause')
    haml :wall_remote
  end

  get '/wall_remote/stop', auth: :user do
    wall_remote_settings
    response = home_api('/itunes/stop')
    haml :wall_remote
  end

  get '/wall_remote/next', auth: :user do
    wall_remote_settings
    response = home_api('/itunes/next')
    haml :wall_remote
  end

  get '/wall_remote/previous', auth: :user do
    wall_remote_settings
    response = home_api('/itunes/previous')
    haml :wall_remote
  end

  get '/wall_remote/volume/up', auth: :user do
    wall_remote_settings
    response = home_api('/itunes/volume/up')
    haml :wall_remote
  end

  get '/wall_remote/volume/down', auth: :user do
    wall_remote_settings
    response = home_api('/itunes/volume/down')
    haml :wall_remote
  end

end
