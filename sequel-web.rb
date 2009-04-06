require 'rubygems'
require 'sinatra'
require File.join(File.dirname(__FILE__), 'lib', 'sequel-web')

set :public, 'public'
set :views,  'views'

get '/' do
  haml :index
end
