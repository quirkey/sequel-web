require 'digest/sha1'
require 'rack-flash'

module Sequel
  module Web
    class App < ::Sinatra::Default

      set :sessions, true
      use Rack::Flash      
      
      set :root, File.join(File.dirname(__FILE__), '..', '..', '..')
      set :app_file, File.expand_path(__FILE__)
      
      def text_field(name, options = {})
        title = options[:title] || name.humanize
        value = options[:value] || ''
        html = "<p>"
        html << "<label for='#{name}'>#{title}</label>"
        html << "<input type='text' name='#{name}' value='#{value}' /></p>"
        html 
      end
          
      get '/' do
        haml :index
      end
      
      post '/connect' do
        # begin
          key = self.class.connect(params[:connection])
          redirect "/database/#{key}"
        # rescue => e
          flash[:warning] = "Error with connection: #{e}"
          # put message in flash
          redirect '/'
        # end
      end
      
      get '/database/:key' do
        load_database
        @tables = @db.tables
        haml :database
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
      
      
      private
      def load_database
        @db = self.class.databases[params[:key]]
        not_found unless @db
      end
    end
  end
end