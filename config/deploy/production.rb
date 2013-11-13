set :stage, :production
set :branch, ENV['REF'] || 'production'

#FIXME: do I need both of these?
set :rack_env, 'production'
set :rails_env, 'production'


set :ssh_key, 'soupstraw-deploy-v1'
ssh_key = 'soupstraw-deploy-v1'

server 'app1.soupstraw.com',
        user: 'deploy',
        roles: %w{web app db},
        ssh_options: {
          keys: [ File.join(ENV['HOME'], '.ssh', ssh_key) ],
          forward_agent: true
        }

# you can set custom ssh options
# it's possible to pass any option but you need to keep in mind that net/ssh understand limited list of options
# you can see them in [net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start)
# set it globally
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
# and/or per server
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
# setting per server overrides global ssh_options

# fetch(:default_env).merge!(rails_env: :production)
