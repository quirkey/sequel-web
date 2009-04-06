require 'rubygems'
require 'bacon'
require 'sinatra'
require 'rack/test'

require File.join(File.dirname(__FILE__), '..', 'lib', 'sequel-web.rb')

Bacon::Context.send(:include, Rack::Test::Methods)

require 'nokogiri'

module TestHelper
  def app
    Sequel::Web::App.set(
    :environment => :test,
    :run => false,
    :raise_errors => true,
    :logging => false
    )
    Sequel::Web::App.new
  end

  def body
    last_response.body.to_s
  end

  def instance_of(klass)
    lambda {|obj| obj.is_a?(klass) }
  end

  # HTML matcher for bacon
  # 
  #    it 'should display document' do
  #      body.should have_element('#document')
  #    end
  #
  # With content matching:
  # 
  #    it 'should display loaded document' do
  #      body.should have_element('#document .title', /My Document/)
  #    end
  def have_element(search, content = nil)
    lambda do |obj|
      doc = Nokogiri.parse(obj.to_s)
      node_set = doc.search(search)
      if node_set.empty?
        false
      else
        collected_content = node_set.collect {|t| t.content }.join(' ')
        case content
        when Regexp
          collected_content =~ content
        when String
          collected_content.include?(content)
        when nil
          true
        end
      end
    end
  end

  def html_body
    body =~ /^\<html/ ? body : "<html><body>#{body}</body></html>"
  end

end

Bacon::Context.send(:include, TestHelper)

class Should

  def have_element(search, content = nil)
    satisfy "have element matching #{search}" do
      doc = Nokogiri.parse(@object.to_s)
      node_set = doc.search(search)
      if node_set.empty?
        false
      else
        collected_content = node_set.collect {|t| t.content }.join(' ')
        case content
        when Regexp
          collected_content =~ content
        when String
          collected_content.include?(content)
        when nil
          true
        end
      end
    end
  end
end