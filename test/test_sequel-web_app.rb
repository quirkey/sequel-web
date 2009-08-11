require File.dirname(__FILE__) + '/test_helper'

describe 'Sequel::Web' do
  before do    
    # set up temporary database
    @test_db_path = '/tmp/test_db.db'
    File.unlink(@test_db_path) if File.readable?(@test_db_path)
    @test_db = Sequel.connect("sqlite://#{@test_db_path}")
    @test_db.create_table :items do
      primary_key :id
      String :name, :unique => true, :null => false
      boolean :active, :default => true
      Time :created_at
    end
    (1..20).each do |n|
      @test_db[:items].insert({:id => n, :name => "test #{n}", :active => true, :created_at => Time.now})
    end
    
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

    describe 'get /quick' do
      before do
        get '/quick', :db => "sqlite:///#{@test_db_path}"
      end
      
      it 'redirects to database index' do
        last_response.should.be.redirect
        last_response.location.should.match /database\/[\w\d]+/
      end
      
    end

    describe 'post /connect' do
      describe 'with legitimate credentials' do
        before do
          post '/connect', :connection => {:adapter => 'sqlite', :database => @test_db_path}
        end

        it 'redirects to database index' do
          last_response.should.be.redirect
          last_response.location.should.match /database\/[\w\d]+/
        end        
      end

      describe 'with illegitimate credentials' do
        before do
          post '/connect', :connection => {:adapter => 'mysql', :database => @test_db_path}
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
        post '/connect', :connection => {:adapter => 'sqlite', :database => @test_db_path}
        @db_key       = last_response['Location'].gsub(/\/database\//,'')
        @last_session = last_request.env['rack.session']
      end

      describe 'get /database' do

        describe 'with a valid DB hash' do
          before do
            get "/database/#{@db_key}/tables", {}, {'rack.session' => @last_session}
          end

          it 'should be successful' do
            last_response.should.be.ok
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
              get "/database/#{@db_key}/tables/items", {}, {'rack.session' => @last_session}
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
              get "/database/#{@db_key}/tables/blah", {}, {'rack.session' => @last_session}
            end

            it 'is a 404' do
              last_response.should.be.not_found
            end
          end
        end
        

        describe 'get /database/table/schema' do
          before do
            get "/database/#{@db_key}/tables/items/schema", {}, {'rack.session' => @last_session}
          end
          
          it 'should display schema as table' do
            body.should.have_element('table#schema')
          end
        end

        describe 'get /database/table/record' do
          before do
            get "/database/#{@db_key}/tables/items/record/1", {}, {'rack.session' => @last_session}
          end
          
          it 'displays details for that row' do
            body.should.have_element('.record')
            body.should.have_element('input[value="test 1"]')
          end

          it 'has form for editing the row' do
            body.should.have_element('.record form label', /name/)
          end
        end
        
        describe 'get /database/table/record with multiple records' do
          before do
            get "/database/#{@db_key}/tables/items/records/1,2,3", {}, {'rack.session' => @last_session}
          end
          
          
          it 'displays details for that row' do
            body.should.have_element('.record')
            body.should.have_element('input[value="test 1"]')
          end

          it 'has form for editing the rows' do
            body.should.have_element('.record form label', /name/)
            body.should.have_element('.record input[name="record[1][name]"]')
          end
        end

        describe 'put /database/table/records with multiple records' do
          before do
            put "/database/#{@db_key}/tables/items/records/1,2", {'record' => {'1' => {'name' => 'test updating'}, '2' => {'active' => false}}}, {'rack.session' => @last_session}
          end
                    
          it 'updates details for that row' do
            @test_db[:items].filter(:id => 1).first[:name].should.equal 'test updating'
            @test_db[:items].filter(:id => 2).first[:active].should.equal false
          end

          it 'has flash message' do
            flash[:message].should.match /success/
          end
          
          it 'displays form with updated data' do
            body.should.have_element('.record form input[name="record[1][name]"][value="test updating"]')
          end
        end  
        
        describe 'delete /database/table/records with multiple records' do
          before do
            @original_count = @test_db[:items].count
            delete "/database/#{@db_key}/tables/items/records/11,12", {}, {'rack.session' => @last_session}
          end
          
          it 'deletes the records' do
            @test_db[:items].count.should.equal (@original_count - 2)
          end 
          
          it 'should have flash message' do
            flash[:message].should.match /deleted/
          end
          
          it 'should redirect to browse' do
            last_response.should.be.redirect
          end
        end

        describe 'get /database/query' do
          before do
            get "/database/#{@db_key}/query", {}, {'rack.session' => @last_session}
          end
          
          it 'displays form for entering sql' do
            body.should.have_element('textarea.query')
          end
        end

        describe 'post /database/query' do
          before do
            @query = 'SELECT * from items where active = \'1\''
            post "/database/#{@db_key}/query", {'query' => @query}, {'rack.session' => @last_session}
          end
          
          it 'shows original query in form' do
            body.should.have_element('textarea.query', @query)
          end

          it 'shows table with results' do
            body.should.have_element('table.dataset')
          end
        end
      end
    end
  end

end