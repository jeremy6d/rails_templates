# Install JQuery
plugin 'jrails', :git => 'git://github.com/aaronchi/jrails.git'
%w{install scrub}.each { |task| rake "jrails:js:#{task}" }