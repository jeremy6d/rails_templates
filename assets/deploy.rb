#  there is a line in the sudoers file that allows webmin to restart nginx
require 'active_support'
DEPLOY_CONFIG = YAML::load(File.open("config/deploy.yml"))
default_run_options[:pty] = true

#
# General Deployment settings
#
set :application, DEPLOY_CONFIG['application']
set :repository,  DEPLOY_CONFIG['repository']
set :scm, :git
unless DEPLOY_CONFIG['staging'].blank?
  set :staging_domain, DEPLOY_CONFIG['staging']['domain']
  set :staging_server, DEPLOY_CONFIG['staging']['server']
  set :staging_branch, DEPLOY_CONFIG['staging']['branch'] || "master"
  set :staging_redirect, DEPLOY_CONFIG['staging']['redirect']
end
unless DEPLOY_CONFIG['production'].blank?
  set :production_domain, DEPLOY_CONFIG['production']['domain']
  set :production_server, DEPLOY_CONFIG['production']['server']
  set :production_branch, DEPLOY_CONFIG['production']['branch'] || "master"
  set :production_redirect, DEPLOY_CONFIG['production']['redirect']
end

#
# some custom actions you may want to use
#
set :package_assets, DEPLOY_CONFIG['package_assets'] || false # set to true if using the asset packager plugin
set :crontasks, DEPLOY_CONFIG['crontasks'] || false # requires a config/crontab/cron-settings 
                      # file in your project (format is the same as a normal crontab file)

#
# Specific deployment target settings
#
task :staging do
  role :app, staging_server
  role :web, staging_server
  role :db,  staging_server, :primary => true
  set :domain, staging_domain
  set :redirect, staging_redirect
  set :branch, staging_branch
  #set :rails_env, 'staging'
  #custom staging logic goes here
end

task :production do
  role :app, production_server
  role :web, production_server
  role :db, production_server, :primary => true
  set :domain, production_domain
  set :redirect, production_redirect  
  set :branch, production_branch
  #custom production logic goes here
end

#
# settings unlikely to change
#
set :web_data, "/data/"  
set :deploy_to, "#{web_data}#{application}"
set :nginx_conf, "#{web_data}conf/"
set :nginx_remote_template, "#{nginx_conf}nginx.erb" 
set :nginx_remote_config, "#{nginx_conf}sites-available/#{application}"
set :database_yml_template, "#{nginx_conf}database.yml.erb"
set :use_sudo, false
set :user, 'webmin'
set(:application_db_pass) {ActiveSupport::SecureRandom.base64(12)}
ssh_options[:port] = 46559
set :deploy_via, :remote_cache
set :git_enable_submodules, 1

#
# insert custom tasks
#
after "deploy:update_code","deploy:symlink_configs"
after("deploy:update_code","deploy:package_assets") if package_assets 
after("deploy:restart", "deploy:write_crontab") if crontasks
after("deploy:setup", "db:setup") unless fetch(:skip_db_setup, false)
after "deploy:setup", "nginx:configure" 
before "deploy:restart", "nginx:configure"  
before "deploy:start", "nginx:configure"


#
# Dynamic nginx config files
# 
# credit: http://www.subreview.com/articles/6
namespace(:nginx) do
  task :configure do
    nginx_template=<<-EOF
    # File generated on <%=Time.now().strftime("%d %b %y")%>
    <% if redirect %>
    server {
                listen   80;
                server_name  <%=redirect %> ;
                rewrite ^/(.*) http://<%=domain %> permanent;
               }
    <% end %>
    
    server {
                listen   80;
                server_name <%=domain %>;

                access_log <%=deploy_to%>/shared/log/access.log;
                error_log  <%=deploy_to%>/shared/log/error.log;

                root   <%=deploy_to%>/current/public/;
                index  index.html;
                passenger_enabled on;
                }
    
    EOF
    
    # run the template  
    template_file(nginx_template,nginx_remote_config)

    #add a symlink into sites enabled 
    run "ln -s -f #{nginx_conf}sites-available/#{application} #{nginx_conf}sites-enabled/#{application}" 
    run "sudo /etc/init.d/nginx reload"
  end

end


namespace(:deploy) do  
  task :symlink_configs, :roles => :app, :except => {:no_symlink => true} do
    run <<-CMD
      cd #{release_path} &&
      ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml &&
      ln -nfs #{shared_path}/system #{release_path}/public/system && 
      ln -s #{shared_path}/news_releases #{release_path}/public/news_releases
    CMD
  end
  
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  task :write_crontab, :roles => :app do
    puts "Installing server-specific crontab."
    run("cd #{deploy_to}/current/config/crontab; crontab cron-settings")
  end
  
  desc "install gems listed in environment.rb"
  task :install_gems do
    run "cd #{current_path} && rake gems:install RAILS_ENV=production"
  end
end

namespace(:monitor) do
  desc "Tail the Rails production log for this environment"
  task :tail_production_logs, :roles => :app do
    run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
      puts  # for an extra line break before the host name
      puts "#{channel[:server]} -> #{data}" 
      break if stream == :err    
    end
  end
end

namespace :db do
  desc "Creates a new database and user, and grants the user rights to the database.  Creates the database.yml configuration file in shared path."
  task :setup, :except => { :no_release => true } do

    database_template=<<-EOF
    # File generated on <%=Time.now().strftime("%d %b %y")%>
    production:
      adapter: mysql
      encoding: utf8
      database: <%= application %> 
      pool: 5
      username: <%= application %>
      password: <%= application_db_pass %>
      socket: /var/run/mysqld/mysqld.sock
    EOF
    
    run "mkdir -p #{shared_path}/db"
    run "mkdir -p #{shared_path}/config"
    
    template_file(database_template,"#{shared_path}/config/database.yml")
    #create the database and user base on the application and password
    run "/data/scripts/user_and_db.rb #{application} #{application_db_pass}"
  end

  desc "Updates the symlink for database.yml file to the just deployed release."
  task :symlink, :except => { :no_release => true } do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end

#
# Get the template as a string,
# parse it, and place the new file on the server
# 
def template_file(template,remote_file_to_put)
    require 'erb'  #render not available in Capistrano 2

    buffer= ERB.new(template).result(binding)   # parse it
    put buffer,remote_file_to_put               # put the result

end