require 'rack-flash'

module Sequel
  module Web
    class App < ::Sinatra::Application

      include ViewHelpers
      include WillPaginate::ViewHelpers
      
      set :sessions, true
      use Rack::Flash      
      
      set :root, File.join(File.dirname(__FILE__), '..', '..', '..')
      set :app_file, File.expand_path(__FILE__)

      before do
        @template = nil
      end

      def database_url(db_key, path)
        "/database/#{db_key}/#{path}"
      end
      
      def database_link(text, db_key, path)
        %{<a href='#{database_url(db_key, path)}'>#{text}</a>}
      end
                  
      get '/stylesheets/styles.css' do
        content_type 'text/css'
        sass :styles
      end
          
      get '/' do
        haml :index
      end
      
      post '/connect' do
        key = connect(params[:connection])
        redirect "/database/#{key}"
      end
      
      get '/database/:key' do
        redirect database_url(params[:key], 'tables') 
      end
      
      get '/database/:key/tables' do
        load_database
        @tables = @db.tables
        haml :tables
      end
      
      get '/database/:key/tables/:table' do
        load_database
        @table = @db[params[:table].to_sym]
        @rows = @table.paginate(params[:page].to_i || 1, params[:per_page] || 10)
        haml :table
      end
      
      
      protected
      
      def session
        @_session ||= env['rack.session']
      end        
      
      def databases
        session[:databases] ||= {}
      end
      
      def connected?
        !!@db
      end
      
      def connect(conn_string)
        @db     = Sequel.connect(conn_string.merge(:loggers => [database_logger]))
        raise "Could not connect to database with credentials provided" unless @db
        db_key = Digest::SHA1.hexdigest(@db.to_s)[0...10]
        self.databases[db_key] = {}.merge(conn_string)
        db_key
      rescue => e
        flash[:warning] = "Error with connection: #{e}"
        redirect '/'
      end
   
      def logger
        @_logger ||= Logger.new(STDOUT)
      end
      
      def database_logger
        @_database_logger ||= Logger.new(database_log)
      end
      
      def database_log
        @_database_log ||= StringIO.new
      end
            
      def load_database
        @db_key = connect(databases[params[:key]])
        not_found unless @db
        @db
      end
      
    end
  end
end