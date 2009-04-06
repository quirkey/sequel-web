module Sequel
  module Web
    class App < Sinatra::Default
      
      set :root, File.join(File.dirname(__FILE__), '..', '..', '..')
      set :public, 'public'
      set :views,  'views'

      get '/' do
        haml :index
      end

    end
  end
end