gem 'redgreen'
gem 'mocha'
gem 'thoughtbot-shoulda', :lib => 'shoulda/rails', :source => 'http://gems.github.com'
gem "cucumber"
gem "webrat"
gem "jnunemaker-matchy", :lib => 'matchy'
gem 'ZenTest'
gem 'autotest-fsevent', :version => '0.1.1'
gem 'autotest-growl'

File.open 'test/test_helper.rb', 'w' do |file|
  file.write <<-TEST_HELPER
    ENV["RAILS_ENV"] = "test"
    require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
    require 'test_help'
    require 'shoulda'
    require 'matchy'
    require 'mocha'

    class ActiveSupport::TestCase
      self.use_transactional_fixtures = true
      self.use_instantiated_fixtures  = false
      fixtures :all

      # Add more helper methods to be used by all tests here...
    end
  TEST_HELPER
end

rake('gems:install', :sudo => true)
generate :cucumber