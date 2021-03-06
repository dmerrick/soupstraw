# application options
set :application, 'soupstraw'
set :domain, "#{fetch(:application)}.com"
set :deploy_to, "/data/#{fetch(:application)}"

# user options
set :user, 'deploy'
set :group, 'deploy'
set :runner, 'deploy'
set :use_sudo, false
set :ssh_key, File.join(ENV['HOME'], '.ssh', 'soupstraw-deploy-v1')
# set :pty, true

# git options
set :scm, :git
set :repo_url, 'git@github.com:dmerrick/soupstraw.git'
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }
set :git_shallow_clone, 1
set :deploy_via, :remote_cache

# symlink options
set :linked_files, %w{config/application.yml config/database.yml config/unicorn.rb config/newrelic.yml}
set :linked_dirs,  %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# rbenv options
set :rbenv_type, :system
set :rbenv_ruby, `cat .ruby-version`.chomp
set :rbenv_custom_path, '/opt/rbenv'

# set to :debug, and :format to :pretty if things are breaking
set :log_level, :info
set :format, :dot

# some defaults to keep around
# set :default_env, { path: "/opt/rbenv/bin:$PATH" }
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart web server'
  task :restart do
    on roles(:web), in: :sequence, wait: 5 do
      # gracefully restart all workers
      # requires preload_app=false in unicorn config
      #execute 'sudo /etc/init.d/unicorn reload'

      #FIXME: this is heavy-handed
      execute 'sudo /etc/init.d/unicorn full-restart'
    end
  end

  task :start do
    on roles(:web), in: :sequence, wait: 5 do
      execute 'sudo /etc/init.d/unicorn start'
    end
  end

  task :stop do
    on roles(:web), in: :sequence, wait: 5 do
      execute 'sudo /etc/init.d/unicorn stop'
    end
  end

  task :status do
    on roles(:web), in: :sequence, wait: 5 do
      execute 'sudo /etc/init.d/unicorn status'
    end
  end

  #TODO: see if the capistrano/rails supports this
  #after "deploy:cold", "deploy:seed"
  #task :seed, :roles => :db do
  #  run "cd #{current_path} && env RAILS_ENV=#{rails_env} bundle exec rake db:seed"
  #end

  # restart unicorn on each deploy
  after :publishing, :restart

  # clean up old releases
  after :finishing, :cleanup
  after :finishing, 'newrelic:notice_deployment'

end

desc "Report uptime for all servers"
task :uptime do
  on roles(:all) do |host|
    info "Host #{host} (#{host.roles.to_a.join(', ')}):\t#{capture(:uptime)}"
  end
end