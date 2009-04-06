require 'rubygems'
require 'sequel'
require 'sinatra'

%w{app}.each do |file|
  require File.join(File.dirname(__FILE__), 'sequel', 'web', file)
end
