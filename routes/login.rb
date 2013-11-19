# encoding: utf-8

class Soupstraw < Sinatra::Base

  # temporary trick to let other people log in
  get '/cheat/:path' do
    session[:user_id] = 1
    redirect params[:path], danger: 'you cheater :p'
  end

  get '/users/:id' do
    @user = User.find(params[:id])
    haml :'users/show'
  end

  post '/log_in' do
    session[:user_id] = User.authenticate(params).id
    redirect back
  end

  get '/log_in' do
    haml :log_in
  end

  get '/log_out' do
    session[:user_id] = @user = nil
    flash.now[:info] = 'You are now logged out.'
    haml :log_in
  end

end
