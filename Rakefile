require 'rubygems'
require 'bundler'
require 'rake'
Bundler.setup
require 'sinatra/activerecord/rake'

require './app'


Dir['lib/tasks/*.rake'].sort.each { |ext| load ext }
