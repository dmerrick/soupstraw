class Soupstraw < Sinatra::Base

  get '/lights', auth: :user do
    @title = 'Light Controls'
    response = home_api('/lights')
    @lights = JSON.parse(response.body)
    @json_data = JSON.pretty_generate(@lights) if request[:with_json]
    haml :lights
  end

  get '/lights/living_room/on', auth: :user do
    wall_remote_settings
    response = home_api('/lights/on')
    haml :wall_remote
  end

  get '/lights/living_room/off', auth: :user do
    wall_remote_settings
    response = home_api('/lights/off')
    haml :wall_remote
  end

  # reset all lights to white
  get '/lights/living_room/reset', auth: :user do
    wall_remote_settings
    response = home_api('/lights/reset')
    haml :wall_remote
  end

  get '/lights/toggle', auth: :user do
    @light_id = request[:light_id] || 1
    redirect "/lights/toggle/#{@light_id}?#{request.query_string}"
  end

  get '/lights/toggle/:id', auth: :user do
    wall_remote_settings
    response = home_api("/lights/toggle/#{params[:id]}?#{request.query_string}")
    haml :wall_remote
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
