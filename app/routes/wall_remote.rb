class Soupstraw < Sinatra::Base

  get '/wall_remote', auth: :user do
    wall_remote_settings
    haml :wall_remote
  end

  get '/wall_remote/:command', auth: :user do
    wall_remote_settings
    command = params[:command]
    @icon = command if %w{play pause}.include? command
    response = home_api("/wall_remote/#{command}")
    haml :wall_remote
  end

end
