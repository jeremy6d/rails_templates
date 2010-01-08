# TODO: add asset packager, hoptoad, google analytics, etc.

%w{base clearance gems throat-punch jquery}.each do |script|
  load_template "/Users/jeremyweiland/Development/my_templates/#{script}.rb"
end

rake 'db:migrate'

message = 'typical.rb: Typical Rails setup complete, including Capistrano, Clearance, and Rspec'

git :add => ".", :commit => "-m '#{message}'"

puts "***** #{message} *****"