ENV['RAILS_ENV'] = 'test'

require "rubygems"
require "bundler"

Bundler.setup
Bundler.require :default, :test

require 'test/unit'

require 'active_record'
require 'sidekick/active_record'

ActiveRecord::Base.configurations = {'test' => {:adapter => "mysql2", :database => "sidekick_test"}}
ActiveRecord::Base.establish_connection('test')
require 'schema'

require 'active_record/test_case'
require 'active_record/fixtures'

# This is WTF. But whatever.
require 'assert_queries_patches'

Dir.glob(File.expand_path(File.join File.dirname(__FILE__), 'models/**/*')).each {|model| require model }

class ActiveSupport::TestCase
  include ActiveRecord::TestFixtures
  self.fixture_path = "./test/fixtures/"

  fixtures :all
end
