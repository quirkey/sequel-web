require File.dirname(__FILE__) + '/test_helper'

describe 'Sequel::Web' do
  before do    
    # set up temporary database
    @test_db_path = '/tmp/test_db.db'
    File.unlink(@test_db_path) if File.readable?(@test_db_path)
    db = Sequel.connect("sqlite://#{@test_db_path}")
    db.create_table :items do
      primary_key :id
      String :name, :unique => true, :null => false
      boolean :active, :default => true
      Time :created_at
    end
    db[:items].insert({:id => 1, :name => 'test', :active => true, :created_at => Time.now})
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
        body.should.have_element('form#connect_form') 
      end

    end

    describe 'post /connect' do
      describe 'with legitimate credentials' do
        before do
          post '/connect', :connection => {:adapter => 'sqlite', :database => '/tmp/test_db.db'}
        end

        it 'redirects to database index' do
          last_response.should.be.redirect
          last_response.location.should.match /database\/[\w\d]+/
        end        
      end

      describe 'with illegitimate credentials' do
        before do
          post '/connect', :connection => {:adapter => 'mysql', :database => '/tmp/test_db.db'}
        end

        it 'should redirect to index' do
          last_response.should.be.redirect
        end

        it 'should put error in flash session' do
          flash[:warning].should.match(/Error/)
        end
      end      
    end

    describe 'after connecting to a database' do
      before do
        post '/connect', :connection => {:adapter => 'sqlite', :database => '/tmp/test_db.db'}
        @db_key = last_response['Location'].gsub(/\/database\//,'')
      end

      describe 'get /database' do

        describe 'with a valid DB hash' do
          before do
            get "/database/#{@db_key}"
            puts body.inspect
          end

          it 'displays list of tables' do
            body.should.have_element('#tables td a', 'items')
          end

          it 'displays menu' do
            body.should.have_element('#db_menu')
          end

        end

        describe 'get /database/table' do
          describe 'with an existing table' do
            before do
              get "/database/#{@db_key}/tables/items"
            end

            it 'displays paginated table of rows' do
              body.should.have_element('table.dataset')
              body.should.have_element('.pagination')
            end

            it 'displays menu' do
              body.should.have_element('#db_menu')
            end
          end

          describe 'with a non existing table' do
            before do
              get "/database/#{@db_key}/tables/blah"
            end

            it 'is a 404' do
              last_response.should.be.not_found
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