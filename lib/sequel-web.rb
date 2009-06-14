require 'rubygems'
require 'sequel'
require 'sequel/extensions/pagination'
require 'sinatra'
require 'active_support'
require 'haml'
require 'will_paginate'
require 'will_paginate/view_helpers'

require 'digest/sha1'

%w{ext web/view_helpers web/app}.each do |file|
  require File.join(File.dirname(__FILE__), 'sequel', file)
end
