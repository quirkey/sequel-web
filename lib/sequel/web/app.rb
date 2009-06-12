require 'rack-flash'

module Sequel
  module Web
    class App < ::Sinatra::Default
      register ViewHelpers
      
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
        key = connect(params[:connection])
        redirect "/database/#{key}"
      end
      
      get '/database/:key' do
        load_database
        @tables = @db.tables
        haml :database
      end
      
      protected
      
      def session
        @_session ||= env['rack.session']
      end        
      
      def databases
        session[:databases] ||= {}
      end
      
      def connect(conn_string)
        @db     = Sequel.connect(conn_string)
        raise "Could not connect to database with credentials provided" unless @db
        db_key = Digest::SHA1.hexdigest(@db.to_s)[0...10]
        self.databases[db_key] = {}.merge(conn_string)
        db_key
      rescue => e
        flash[:warning] = "Error with connection: #{e}"
        redirect '/'
      end
            
      def load_database
        connect(databases[params[:key]])
        not_found unless @db
        @db
      end
      
    end
  end
end