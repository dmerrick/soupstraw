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

end
