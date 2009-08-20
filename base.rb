# Base template for Rails projects
# written by Jeremy Weiland (http://jeremyweiland.com)

# git:rails:new_app
git :init

# setup base README
run "echo Written by Jeremy Weiland \\(http://6thdensity.net\\) \\nNo intellectual property rights of any kind claimed\\; however, misattribution is fraudlent. > README"

# rails:rm_tmp_dirs
["./tmp/pids", "./tmp/sessions", "./tmp/sockets", "./tmp/cache"].each do |f|
  run("rmdir ./#{f}")
end


run("rm public/index.html")

# git:hold_empty_dirs
run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run %{find . -type d -empty | grep -v "vendor" | grep -v ".git" | grep -v "tmp" | xargs -I xxx touch xxx/.gitignore}

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
git :add => "."
git :commit => "-a -m 'Initial commit.'"