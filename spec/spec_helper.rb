# spec/spec_helper.rb
require 'rack/test'
require 'rspec'
require 'capybara'
require 'capybara/dsl'
require 'dm-rspec'
require "rack_session_access"
require "rack_session_access/capybara"
ENV['RACK_ENV'] = 'test'

require File.expand_path '../../app.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  include Capybara::DSL # Adding this line solved the error

  def app() Sinatra::Application end
end

  class Capybara::Session
    def submit(element)
      Capybara::RackTest::Form.new(driver, element.native).submit({})
    end
  end


Capybara.app = Sinatra::Application

# For RSpec 2.x and 3.x
RSpec.configure do |c|
	c.include RSpecMixin 
	c.include Capybara
	c.include(DataMapper::Matchers)

	DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/app.db")
  	DataMapper.finalize
  	User.auto_migrate!
  	Video.auto_migrate!
  	Capybara.app.use RackSessionAccess::Middleware
end

def session
  last_request.env['rack.session']
end