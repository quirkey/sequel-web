require 'rubygems'
require 'sequel'
require 'sinatra'
require 'active_support'
require 'haml'

require 'digest/sha1'


%w{view_helpers app}.each do |file|
  require File.join(File.dirname(__FILE__), 'sequel', 'web', file)
end
