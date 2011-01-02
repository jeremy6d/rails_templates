# Base template for Rails projects
# written by Jeremy Weiland (http://jeremyweiland.com)

git :init
file 'README', <<-README
Written by Jeremy Weiland (http://6thdensity.com)
No intellectual property rights of any kind claimed; however, misattribution is fraudlent.
Copyleft 2010 6th Density LLC
README
["./tmp/pids", "./tmp/sessions", "./tmp/sockets", "./tmp/cache"].each do |f|
  run("rmdir ./#{f}")
end
run("rm public/index.html")

file '.gitignore', <<-CODE
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
CODE

file 'Gemfile', <<-CODE
source 'http://rubygems.org'

gem 'rails', '3.0.1'
gem 'haml'
gem 'haml-rails'
gem "mongoid", "2.0.0.beta.17"
gem "bson_ext", "1.0.4"
gem 'inherited_resources'
gem 'formtastic'

group :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'autotest'
  gem 'autotest-growl'
  gem 'autotest-fsevent'
  gem "mocha"
  gem 'database_cleaner'
  gem 'cucumber-rails'
  gem 'cucumber'
  gem 'pickle'
  gem 'pickle-mongoid'
  gem 'launchy'
end

group :test, :development do
  gem 'ruby-debug'
end
CODE

run "bundle install"

application do %q{
  config.action_view.javascript_expansions[:defaults] = %w()
  config.encoding = "utf-8"
  config.filter_parameters += [:password]
  config.time_zone = 'Eastern Time (US & Canada)'

  config.generators do |g|
    g.orm                 :mongoid
    g.template_engine     :haml
    g.test_framework      :micronaut, :fixture => true, 
                                      :views => false
    g.fixture_replacement :factory_girl, :dir => "test/factories"
  end 
}
end

# inside 'lib/generators' do
#   run 'git clone git://github.com/pjb3/rails3-generators.git'
# end

run 'touch config/database.yml'

generate 'mongoid:config'
generate 'rspec:install'
generate 'formtastic:install'
generate 'cucumber:install --rspec --capybara --skip-database'
generate 'pickle'

run 'rm config/database.yml'

inside('public/javascripts') do
	FileUtils.rm_rf %w(controls.js dragdrop.js effects.js prototype.js rails.js)
end
get "http://code.jquery.com/jquery-latest.min.js", "public/javascripts/jquery.js"
get "https://github.com/rails/jquery-ujs/raw/master/src/rails.js", "public/javascripts/rails.js"
initializer 'jquery.rb', <<-CODE
# Switch the javascript_include_tag :defaults to
# use jQuery instead of the default prototype helpers.
# Also setup a :jquery expansion, just for good measure.
# Written by: Logan Leger, logan@loganleger.com
# http://github.com/lleger/Rails-3-jQuery

ActionView::Helpers::AssetTagHelper.register_javascript_expansion :jquery => ['jquery', 'rails']
ActiveSupport.on_load(:action_view) do
  ActiveSupport.on_load(:after_initialize) do
    ActionView::Helpers::AssetTagHelper::register_javascript_expansion :defaults => ['jquery', 'rails']
  end
end
CODE

spec_helper_path = 'spec/spec_helper.rb'
gsub_file spec_helper_path, 'config.fixture_path = "#{::Rails.root}/spec/fixtures"', ''
gsub_file spec_helper_path, /(config.use_transactional_fixtures = true)/, ''
gsub_file spec_helper_path, "config.mock_with :rspec", "config.mock_with :mocha"
mongoid_rspec_truncation = <<-MONGOID
  config.before :each do
    Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)
  end
MONGOID
    
inject_into_file spec_helper_path, mongoid_rspec_truncation, :after => "# config.use_transactional_fixtures = true\n"

wipe_cuke_db = <<-CUKE
  Before do
    Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)
  end
CUKE

inject_into_file "features/support/env.rb", wipe_cuke_db, :after => "ActionController::Base.allow_rescue = false"

git :add => "."
git :commit => "-m 'Initial commit.'"