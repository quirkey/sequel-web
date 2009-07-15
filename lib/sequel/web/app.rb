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
        url = database_url(db_key, path)
        logger.info "url: #{url}, path_info: #{request.path_info}"
        active = ((url == request.path_info) ? 'active' : '')
        %{<a href='#{url}' class="#{active}">#{text}</a>}
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
        @table_name = params[:table]
        @table = @db[@table_name.to_sym]
        @primary_key = primary_key_for(@table_name)
        logger.info "-- primary_key:" + @primary_key.inspect
        @rows = @table.paginate(page, per_page)
        haml :table
      end
      
     get '/database/:key/tables/:table/schema' do
        load_database
        @schema = schema(params[:table])
        haml :schema
      end
      
      get '/database/:key/query' do
        load_database
        haml :query
      end      
      
      post '/database/:key/query' do
        load_database
        @query = @db[params[:query]]
        logger.debug @query.inspect
        @rows = @query.paginate(page, per_page)
        haml :query
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
      
      def connect(conn_string, db_key = nil)
        @db     = Sequel.connect(conn_string.merge(:loggers => [database_logger, logger]))
        raise "Could not connect to database with credentials provided" unless @db
        @db.tables # try to execute a query
        
        db_key ||= Digest::SHA1.hexdigest(@db.to_s)[0...10]
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
        @db_key = connect(databases[params[:key]], params[:key])
        not_found unless @db
        @db
      end
      
      def schema(table = nil, reload = false)
        @schemas ||= {}
        @schemas[@db_key] = (@schemas[@db_key] && !reload) ? @schemas[@db_key] : @db.schema
        table ? @schemas[@db_key][table] : @schemas[@db_key]
      end
      
      def primary_key_for(table)
        key = schema(table).find {|k,v| v[:primary_key] === true }
        key ? key[0] : false
      end
      
      def page(default = 1)
        (params[:page] ? params[:page] : default).to_i
      end
      
      def per_page(default = 10)
        (params[:per_page] ? params[:per_page] : default).to_i
      end
      
    end
  end
end