# Set up capistrano for a project

run "capify ."    

inside('config') do
  app_name = Dir.pwd.split('/').last
  file 'deploy.rb', File.read('http://github.com/inmunited/rails_templates/raw/master/assets/deploy.rb')
            
  file 'deploy.yml', <<-DEPLOY_YML
    application:    "#{app_name}"
    repository:     "git@github.com:inmunited/#{app_name}.git"
    crontasks:      no
    package_assets: no

    staging:
        server:     "67.23.27.232"
        domain:     "#{app_name}.inmunited.com"
        branch:     "master"

    production:
        server:     "174.143.237.222"
        domain:     "www.#{app_name}.com"
        redirect:   "#{app_name}.com"
        branch:     "master"
  DEPLOY_YML
end