#incomplete

gem 'capistrano', :version => '~>2'

rake('gems:install', :sudo => true)

# Capify and create production environment.rb  
run 'capify .'

app_name = Dir.pwd.split("/").last

file 'config/deploy.rb', %q{
  set :application, appname
  set :repository,  "http://github.com/jeremy6d/#{app_name}"
  set :scm, :git
  set :domain, DOMAIN_TO_SET
  set :branch, 'master'
  set :deploy_via, :remote_cache
  set :deploy_to, "/var/www/#{app_name}"
  role :web, "potentiator"
  
  load 'ext/rails-database-migrations.rb'
  load 'ext/rails-shared-directories.rb'
  
  load 'ext/spinner.rb'              # Designed for use with script/spin
  load 'ext/passenger-mod-rails.rb'  # Restart task for use with mod_rails
  load 'ext/web-disable-enable.rb'   # Gives you web:disable and web:enable

  namespace(:monitor) do
    desc "Tail the Rails production log for this environment"
    task :tail, :roles => :app do
      run "tail -f /var/www/#{app_name}/shared/log/production.log" do |channel, stream, data|
        puts  # for an extra line break before the host name
        puts "#{channel[:server]} -> #{data}" 
        break if stream == :err    
      end
    end
  end
}

gem 'palmtree'