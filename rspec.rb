gem "rspec", :lib => false, :version => ">= 1.2.0"
gem "rspec-rails", :lib => false, :version => ">= 1.2.0"

rake('gems:install', :sudo => true)

File.open 'config/environments/test.rb', 'a' do |file|
  file.write <<-CONFIG_FILE
    config.gem "rspec", :lib => false, :version => ">= 1.2.0"
    config.gem "rspec-rails", :lib => false, :version => ">= 1.2.0"
  CONFIG_FILE
end

generate :rspec