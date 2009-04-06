require 'test_helper'

describe 'Sequel::Web' do
  before do    
    # set up temporary database
    File.unlink('/tmp/test_db.db')
    db = Sequel.connect('sqlite:///tmp/test_db.db')
    db.create_table :items do
      primary_key :id
      String :name, :unique => true, :null => false
      boolean :active, :default => true
      Time :created_at
    end
    db[:items].insert({:id => 1})
  end

  describe 'App' do

    describe 'get /' do
      before do
        get '/'
      end

      it 'loads the index' do
        last_response.should.be.ok
      end

      it 'displays form for connecting to a database' do
        body.should have_element('form#connect_form') 
      end

    end

    describe 'post /connect' do
      describe 'with legitimate credentials' do
        before do
          post '/connect', :connection => {:type => 'sqlite', :path => '/tmp/test_db.db'}
        end

        it 'adds to database list in current class' do
          Sequel::Web::App.databases.should.be.instance_of Hash
          Sequel::Web::App.databases.values.first.should.be.instance_of Sequel::Database
        end

        it 'redirects to database index' do
          last_response.should.be.redirect
        end        
      end

      describe 'with illegitimate credentials' do
        before do
          post '/connect', :connection => {:adapter => 'sqlite', :database => '/tmp/test_db.db'}
        end

        it 'should redirect to index' do
          last_response.should.be.redirect
        end

        it 'should put error in flash session' do
          should.flunk
        end
      end      
    end

    describe 'after connecting to a database' do
      before do
        Sequel::Web::App.connect(:adapter => 'sqlite', :database => '/tmp/test_db.db')
        @db_key = Sequel::Web::App.databases.keys.first
      end

      describe 'get /database' do

        describe 'with a valid DB hash' do
          before do
            get "/database/#{@db_key}"
          end

          it 'displays list of tables' do
            body.should have_element('#tables td a', 'items')
          end

          it 'displays menu' do
            body.should have_element('#db_menu')
          end

        end

        describe 'get /database/table' do
          describe 'with an existing table' do
            before do
              get "/database/#{@db_key}/items"
            end

            it 'displays paginated table of rows' do
              body.should have_element('table#items')
              body.should have_element('.pagination')
            end

            it 'displays menu' do
              body.should have_element('#db_menu')
            end
          end

          describe 'with a non existing table' do
            before do
              get "/database/#{@db_key}/items"
            end

            it 'is a 404' do
              last_response.should.be.error
            end
          end
        end
        

        describe 'get /database/table/schema' do
          
          it 'should display schema as table' do
            
          end
        end

        describe 'get /database/table/row' do
          it 'displays details for that row' do

          end

          it 'has form for editing the row' do

          end
        end

        describe 'PUT /database/table/row' do
          it 'updates details for that row' do

          end

          it 'has flash message' do
            
          end
          
          it 'displays form with updated data' do

          end
        end

        describe 'get /database/query' do
          it 'displays form for entering sql' do

          end
        end

        describe 'post /database/query' do
          it 'shows original query in form' do

          end

          it 'shows table with results' do

          end
        end
      end
    end
  end

end