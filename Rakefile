require 'rubygems'
require 'bundler'
require 'rake'
Bundler.setup
require 'sinatra/activerecord/rake'

require './app'


Dir["tasks/*.rake"].sort.each { |ext| load ext }
