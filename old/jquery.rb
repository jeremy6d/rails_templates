# Install JQuery
plugin 'jrails', :git => 'git://github.com/aaronchi/jrails.git'
%w{install scrub}.each { |task| rake "jrails:js:#{task}" }
%w{controls dragdrop effects prototype}.each do |filename|
  git :rm => "public/javascripts/#{filename}.js"
end