class Soupstraw < Sinatra::Base

  get '/lights/on' do
    response = home_api('/lights/on')
    response.body
  end

  get '/lights/off' do
    response = home_api('/lights/on')
    response.body
  end

end
