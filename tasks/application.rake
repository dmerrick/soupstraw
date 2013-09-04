desc 'Run the app'
task :s do
  system "rackup -p 4567"
end

task :s9393 do
  system "rackup -p 9393"
end
