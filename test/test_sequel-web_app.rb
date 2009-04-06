require 'test_helper'

describe 'Sequel::Web' do
  before do
    def app
      Sequel::Web::App.set(:environment => :test,
      :run => false,
      :raise_errors => true,
      :logging => false
      )
      Sequel::Web::App.new
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
        
      end

    end

    describe 'post /connect' do
      describe 'with legitimate credentials' do

        it 'adds to database list in current class' do

        end

        it 'redirects to database index' do

        end        
      end

      describe 'with illegitimate credentials' do

        it 'should redirect to index' do

        end

        it 'should put error in flash session' do

        end
      end      
    end
    
    describe 'get /database' do
      
      describe 'with a valid DB hash' do
        
        it 'displays list of tables' do
          
        end
        
        it 'displays menu' do
          
        end
        
      end
      
    end
    
    describe 'get /database/table' do
      
      it 'displays paginated table of rows' do
        
      end
      
      it 'displays menu' do
        
      end
      
    end
    
    describe 'get /database/table/row' do
      it 'displays details for that row' do
        
      end
      
      it 'has form for editing the row' do
        
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