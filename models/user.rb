class User < ActiveRecord::Base

  attr_accessible :email, :password, :password_confirmation

  attr_accessor :password
  before_save :encrypt_password

  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :name
  validates_presence_of :email
  validates_uniqueness_of :email

  def first_name
    name.split.first
  end

  def self.authenticate(options)
    user = find_by_email(options[:email].downcase)
    if user && user.password_hash == BCrypt::Engine.hash_secret(options[:password], user.password_salt)
      user
    else
      nil
    end
  end

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

end

__END__

# something for later?
get '/users' do
  @users = User.all
  haml :'users/index'
end
