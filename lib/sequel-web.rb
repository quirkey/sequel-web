require 'rubygems'
require 'sequel'
require 'sequel/extensions/pagination'
require 'sinatra'
require 'active_support'
require 'haml'
require 'sass'
require 'will_paginate'
require 'will_paginate/view_helpers'

require 'digest/sha1'

module Sequel
  module Web
    VERSION = '0.0.1'
  end
end

%w{ext web/view_helpers web/app}.each do |file|
  require File.join(File.dirname(__FILE__), 'sequel', file)
end