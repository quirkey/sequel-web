require 'rack-flash'

module Sequel
  module Web
    class App < ::Sinatra::Application

      include ViewHelpers
      include WillPaginate::ViewHelpers

      set :sessions, true
      use Rack::Flash      
      set :methodoverride, true

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

      get '/quick' do
        key = connect(URI.parse(params[:db]))
        redirect "/database/#{key}"
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
        load_table
        @table = @table.restful_query(params[:query]) if params[:query]
        @rows = @table.paginate(page, per_page)
        haml :table
      end

      get '/database/:key/tables/:table/record/:id' do
        load_database
        load_table
        @record = @table.first({@primary_key => params[:id]})
        haml :record
      end

      get '/database/:key/tables/:table/records/:ids' do
        load_database
        load_table
        ids = params[:ids].split(',')
        @records = @table.filter({@primary_key => ids}).all
        haml :records
      end

      put '/database/:key/tables/:table/record/:id' do
        begin
          load_database
          load_table
          @record = @table.filter({@primary_key => params[:id]})
          @record.update(params[:record]) if params[:record]
          @record = @record.first
          flash[:message] = "Record updated successfully"
        rescue Sequel::Error => e
          flash[:warning] = "Record could not be updated: #{e}"
        end
        haml :record
      end

      put '/database/:key/tables/:table/records/:ids' do
        begin
          load_database
          load_table
          ids = params[:ids].split(',').compact
          @records = []
          ids.each do |i|          
            record = @table.filter({@primary_key => i})
            record.update(params[:record][i]) if params[:record][i]
            @records << record.first
          end
          @records.compact!
          flash[:message] = "Record updated successfully"
        rescue Sequel::Error => e
          flash[:warning] = "Record could not be updated: #{e}"
        end
        haml :records
      end
      
      delete '/database/:key/tables/:table/records/:ids' do
        begin
          load_database
          load_table
          ids = params[:ids].split(',').compact
          @table.filter({@primary_key => ids}).delete
          flash[:message] = "#{ids.length} records deleted."
        rescue Sequel::Error => e
          flash[:warning] = "Record could not be updated: #{e}"
        end
        redirect database_url(@db_key, "tables/#{@table_name}")
      end

      get '/database/:key/tables/:table/schema' do
        load_database
        load_table
        @schema = @db.schema(@table_name)
        haml :schema
      end

      get '/database/:key/query' do
        load_database
        haml :query
      end      

      post '/database/:key/query' do
        load_database
        begin
          @raw_query = params[:query]
          @query = @db[@raw_query]
          @rows = @query.paginate(page, per_page)
        rescue Sequel::DatabaseError => e
          flash[:warning] = "There was an error with your query: #{e}"
        end
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
        @_logger ||= Logger.new(test? ? StringIO.new : STDOUT)
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
      
      def load_table
        @table_name = params[:table]
        @table = @db[@table_name.to_sym]
        @primary_key = primary_key_for(@table_name)
        logger.info "-- primary_key:" + @primary_key.inspect
      rescue Sequel::Error => e
        logger.error "Error while loading table: #{e}"
        not_found
      end

      def primary_key_for(table)
        @schema ||= @db.schema(table)
        key = @schema.find {|k,v| v[:primary_key] === true }
        key ? key[0] : false
      end

      def page(default = 1)
        (params[:page] ? params[:page] : default).to_i
      end

      def per_page(default = 20)
        (params[:per_page] ? params[:per_page] : default).to_i
      end

    end
  end
end