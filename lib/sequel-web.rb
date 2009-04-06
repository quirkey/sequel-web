require 'rubygems'
require 'sequel'
require 'sinatra'
require 'active_support'

%w{app}.each do |file|
  require File.join(File.dirname(__FILE__), 'sequel', 'web', file)
end
