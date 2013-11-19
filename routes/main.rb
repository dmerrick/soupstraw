# encoding: utf-8

class Soupstraw < Sinatra::Base

  before do
    @user = User.find(session[:user_id]) if session[:user_id]
  end

  get '/?' do
    # redirect to the dual stats page
    redirect '/bitcoins/1+2'
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
