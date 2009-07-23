# inm_base.rb
# from Jeremy Weiland

# setup base README
run "echo ©#{Time.now.year} INM United, all rights reserved. > README"

# rails:rm_tmp_dirs
["./tmp/pids", "./tmp/sessions", "./tmp/sockets", "./tmp/cache"].each do |f|
  run("rmdir ./#{f}")
end

# git:rails:new_app
git :init

# git:hold_empty_dirs
run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run %{find . -type d -empty | grep -v "vendor" | grep -v ".git" | grep -v "tmp" | xargs -I xxx touch xxx/.gitignore}

# Rspec

plugin "rspec", :git => "git://github.com/dchelimsky/rspec.git", :submodule => true
plugin "rspec-rails", :git => "git://github.com/dchelimsky/rspec-rails.git", :submodule => true
generate :rspec

# Install JQuery

run "curl -L http://jqueryjs.googlecode.com/files/jquery-1.3.2.min.js > public/javascripts/jquery.js"
run "curl -L http://jqueryui.com/download/jquery-ui-1.7.1.custom.zip > public/javascripts/jquery-ui.js"
plugin 'jrails', :git => 'git://github.com/jauderho/jrails.git', :submodule => true

# gem setup

gem 'mislav-will_paginate', :version => '~> 2.2.3', 
                            :lib => 'will_paginate', 
                            :source => 'http://gems.github.com'
gem 'rubyist-aasm', :lib => 'aasm', :source => 'http://gems.github.com'

# restful_authentication

plugin 'restful_authentication', :git => 'git://github.com/technoweenie/restful-authentication.git', 
                                 :submodule => true

# resource_controller

plugin 'resource_controller', :git => "git://github.com/giraffesoft/resource_controller.git", :submodule => true  

# install gems
rake('gems:install', :sudo => true)

# generate users / sessions?

if yes?("Generate users / sessions?")
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
