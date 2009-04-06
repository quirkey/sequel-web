require 'test_helper'

describe 'Sequel-web' do

  
  it 'should load the index' do
    get '/'
    should.be.ok
  end
end

