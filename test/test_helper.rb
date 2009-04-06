require 'rubygems'
require 'bacon'
require 'sinatra'
require 'rack/test'

require File.join(File.dirname(__FILE__), '..', 'lib', 'sequel-web.rb')

Bacon::Context.send(:include, Rack::Test::Methods)