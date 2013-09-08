class User < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :email
end

__END__

# something for later?
get '/users' do
  @users = User.all
  haml :'users/index'
end
