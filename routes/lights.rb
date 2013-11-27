class Soupstraw < Sinatra::Base

  get '/lights/on', auth: :user do
    response = home_api('/lights/on')
    response.body
  end

  get '/lights/off', auth: :user do
    response = home_api('/lights/off')
    response.body
  end

end
