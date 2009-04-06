# To use with thin 
#  thin start -p PORT -R config.ru

require File.join(File.dirname(__FILE__), 'lib', 'sequel-web.rb')

disable :run
set :environment, :production
run Sequel::Web::App