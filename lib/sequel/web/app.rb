require 'digest/sha1'

module Sequel
  module Web
    class App < Sinatra::Default
      
      set :root, File.join(File.dirname(__FILE__), '..', '..', '..')
      set :public, 'public'
      set :views,  'views'

      def text_field(name, options = {})
        title = options[:title] || name.humanize
        value = options[:value] || ''
        html = "<p>"
        html << "<label for='#{name}'>#{title}</label>"
        html << "<input type='text' value='#{value}' /></p>"
        html 
      end
      
      class << self
        
        def databases
          @@databases ||= {}
        end
        
        def connect(conn_string)
          db     = Sequel.connect(conn_string)
          tables = db.tables
          key    = Digest::SHA1.hexdigest(conn_string.to_s)
          self.databases[key] = db
          key
        end
        
      end
      
      get '/' do
        haml :index
      end
      
      post '/connect' do
        begin
          key = self.class.connect(params[:connection])
          redirect "/database/#{key}"
        rescue => e
          # put message in flash
          redirect '/'
        end
      end
      
      get '/database/:key' do
        load_database
        @tables = @db.tables
        haml :database
      end
      
      private
      def load_database
        @db = self.class.databases[params[:key]]
        not_found unless @db
      end
    end
  end
end