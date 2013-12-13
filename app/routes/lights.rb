class Soupstraw < Sinatra::Base

  get '/lights', auth: :user do
    @title = 'Light Controls'
    response = home_api('/lights')
    @lights = JSON.parse(response.body)
    @json_data = JSON.pretty_generate(@lights) if request[:with_json]
    haml :lights
  end

  get '/lights/on', auth: :user do
    response = home_api('/lights/on')
    #TODO: make this actually take advantage of the response
    redirect '/lights', info: 'Lights are now on.'
  end

  get '/lights/off', auth: :user do
    response = home_api('/lights/off')
    #TODO: make this actually take advantage of the response
    redirect '/lights', info: 'Lights are now off.'
  end

  get '/lights/flash/?', auth: :user do
    @light_id = request[:light_id] || 1
    redirect "/lights/flash/#{@light_id}?#{request.query_string}"
  end

  get '/lights/flash/:id', auth: :user do
    response = home_api("/lights/flash/#{params[:id]}?#{request.query_string}")

    #TODO: make this better
    content_type :json
    response.body
  end

end
