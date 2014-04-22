class Soupstraw < Sinatra::Base

  before do
    @user = User.find(session[:user_id]) if session[:user_id]
  end

  # redirect to to path specified in application.yml
  get '/?' do
    redirect settings.app[:default_path] || '/home'
  end

  get '/home' do
    @title = 'Soupstraw!'
    haml :index
  end

  # list all of the available themes
  get '/themes' do
    @title = 'Available Themes'
    @themes = Dir.glob("#{settings.public_folder}/stylesheets/bootstrap/*.min.css")
    @themes.map! {|theme| theme.sub(/^.*\//, '')}
    # remove the default bootstrap files
    @themes.delete "bootstrap.min.css"
    @themes.delete "bootstrap-theme.min.css"
    @themes.map! {|theme| theme.sub('.bootstrap.min.css', '')}
    @themes.sort!
    haml :themes
  end

  get '/deafguy' do
    response = home_api('/')
    @content = response.body
    haml :blank
  end

  # return OK if deafguy is alive and
  # running the right configuration
  get '/healthcheck/deafguy' do
    content_type 'text/plain'
    response = home_api('/')
    return 'NODEAFGUY' unless response.body =~ /deafguy/
    'OK'
  end

  # return OK if the media center is alive and
  # running the right configuration
  get '/healthcheck/mediacenter' do
    content_type 'text/plain'
    response = home_api('/healthcheck/mediacenter')
    return response.body unless response.body =~ /OK/
    'OK'
  end

end
