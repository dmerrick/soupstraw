set :application, 'soupstraw'
set :domain, "#{fetch(:application)}.com"
set :deploy_to, "/data/#{fetch(:application)}"

set :user, 'deploy'
set :group, 'deploy'
set :runner, 'deploy'
set :use_sudo, false
# set :pty, true

set :scm, :git
set :repo_url, 'git@github.com:dmerrick/soupstraw.git'
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }
set :git_shallow_clone, 1
set :deploy_via, :remote_cache

set :linked_files, %w{config/database.yml config/unicorn.rb}
set :linked_dirs,  %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :rbenv_type, :system
set :rbenv_ruby, '2.0.0-p247'
set :rbenv_custom_path, '/opt/rbenv'

# some defaults to keep around
# set :default_env, { path: "/opt/rbenv/bin:$PATH" }
# set :keep_releases, 5
# set :format, :pretty
# set :log_level, :debug

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      #TODO: consider changing to reload or something else
      execute 'sudo /etc/init.d/unicorn restart'
    end
  end

  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      execute 'sudo /etc/init.d/unicorn start'
    end
  end

  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      execute 'sudo /etc/init.d/unicorn stop'
    end
  end

  task :status do
    on roles(:app), in: :sequence, wait: 5 do
      execute 'sudo /etc/init.d/unicorn status'
    end
  end

  #TODO: see if the capistrano/rails supports this
  #after "deploy:cold", "deploy:seed"
  #task :seed, :roles => :db do
  #  run "cd #{current_path} && env RAILS_ENV=#{rails_env} bundle exec rake db:seed"
  #end

  after :finishing, 'deploy:cleanup'
  #TODO: consider implementing this
  #after :finishing, 'newrelic:notice_deployment'

end

desc "Report uptime for all servers"
task :uptime do
  on roles(:all) do |host|
    info "Host #{host} (#{host.roles.to_a.join(', ')}):\t#{capture(:uptime)}"
  end
end