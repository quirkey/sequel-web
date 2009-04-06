require 'digest/sha1'

module Sequel
  module Web
    class App < Sinatra::Default
      
      set :root, File.join(File.dirname(__FILE__), '..', '..', '..')
      set :public, 'public'
      set :views,  'views'

      class << self
        
        def databases
          @databases || {}
        end
        
        def connect(conn_string)
          db     = Sequel.connect(conn_string)
          tables = db.tables
          self.databases[Digest::SHA1.hexdigest(conn_string.to_s)] = db
        end
        
      end
      
      
      get '/' do
        haml :index
      end
      
    end
  end
end