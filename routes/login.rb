class Soupstraw < Sinatra::Base

  get '/users/:id' do
    @user = User.find(params[:id])
    haml :'users/show'
  end

  post '/log_in' do
    user = User.authenticate(params)
    if user
      session[:user_id] = user.id
      redirect '/'
    else
      flash.now[:warning] = 'Something went awry!'
      redirect back
    end
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
