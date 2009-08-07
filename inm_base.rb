# TODO: integrate deploy.rb and generation of deploy.yml
# TODO: capify out of box
# TODO: move deploy.yml to assets and evaluate with ERB
# TODO: better divination of app name

# inm_base.rb - A template for new Rails apps at INM United (http://github.com/jeremy6d/inm_templates/inm_base.rb)
# ©2009 INM United, All Rights Reserved. (http://inmunited.com)
# written by Jeremy Weiland (http://jeremyweiland.com)

# git:rails:new_app
git :init

# setup base README
run "echo ©#{Time.now.year} INM United, all rights reserved. > README"

# rails:rm_tmp_dirs
["./tmp/pids", "./tmp/sessions", "./tmp/sockets", "./tmp/cache"].each do |f|
  run("rmdir ./#{f}")
end

# git:hold_empty_dirs
run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run %{find . -type d -empty | grep -v "vendor" | grep -v ".git" | grep -v "tmp" | xargs -I xxx touch xxx/.gitignore}

# gem setup

gem 'mislav-will_paginate', :version => '~> 2.2.3', 
                            :lib => 'will_paginate', 
                            :source => 'http://gems.github.com'
gem 'rubyist-aasm', :lib => 'aasm', 
                    :source => 'http://gems.github.com'
gem 'capistrano-capistrano', :version => '~>2',
                             :lib => 'capistrano', 
                             :source => 'http://gems.github.com'

# capify, bitch!

run "capify ."    
run 'curl -L http://github.com/inmunited/rails_templates/raw/master/assets/deploy.rb > config/deploy.rb'
app_name = Dir.pwd.split('/').last              
file 'config/deploy.yml', <<-DEPLOY_YML
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

# Rspec

plugin "rspec", :git => "git://github.com/dchelimsky/rspec.git", :submodule => true
plugin "rspec-rails", :git => "git://github.com/dchelimsky/rspec-rails.git", :submodule => true
generate :rspec

# Install JQuery

run "curl -L http://jqueryjs.googlecode.com/files/jquery-1.3.2.min.js > public/javascripts/jquery.js"
run "curl -L http://jqueryui.com/download/jquery-ui-1.7.1.custom.zip > public/javascripts/jquery-ui.js"
plugin 'jrails', :git => 'git://github.com/jauderho/jrails.git', :submodule => true

# resource_controller

plugin 'resource_controller', :git => "git://github.com/giraffesoft/resource_controller.git", :submodule => true  

# install gems
rake('gems:install', :sudo => true)

# generate users / sessions?

if yes?("Generate users / sessions?")
  plugin 'restful_authentication', :git => 'git://github.com/technoweenie/restful-authentication.git', 
                                   :submodule => true
  generate("authenticated", "user session --include activation --stateful --rspec")                              
end

# set up git ignores

file '.gitignore', <<-CODE
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
CODE

# templatize database setup

run "cp config/database.yml config/database.yml.sample"

# Initialize submodules

git :submodule => "init"

# now commit

git :add => "."

git :commit => "-a -m 'Setting up a new rails app. Copy config/database.yml.sample to config/database.yml and customize.'"

puts "Done. INM fa life!"