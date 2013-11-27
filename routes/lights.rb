class Soupstraw < Sinatra::Base

  get '/lights/on', auth: :user do
    response = home_api('/lights/on')
    @content = response.body
    haml :blank
  end

  get '/lights/off', auth: :user do
    response = home_api('/lights/off')
    @content = response.body
    haml :blank
  end

end
