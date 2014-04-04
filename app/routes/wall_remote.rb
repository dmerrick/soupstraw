class Soupstraw < Sinatra::Base

  get '/wall_remote', auth: :user do
    @title = 'Soupstraw Wall Remote!'
    @no_navbar = true
    haml :wall_remote
  end

end
