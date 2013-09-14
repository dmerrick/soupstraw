# config/unicorn.rb
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)

pidfile = "tmp/pids/unicorn.pid"
pid pidfile

timeout 30

stderr_path "log/unicorn.stderr.log"
stdout_path "log/unicorn.stdout.log"

preload_app true

before_fork do |server, worker|
  old_pid = "#{pidfile}.oldbin"
  if File.exists?(old_pid) and server.pid != old_pid
    begin
      Process.kill('QUIT', File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end

  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection_handler.clear_all_connections!
  end

end

after_fork do |server, worker|

end
