require 'rubygems'
require 'bundler'
require 'rake'
require 'sinatra/activerecord/rake'
Bundler.setup

require './app'


Dir["tasks/*.rake"].sort.each { |ext| load ext }
