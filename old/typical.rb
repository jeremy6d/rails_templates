# TODO: add asset packager, hoptoad, google analytics, etc.

default_templates = %w{base gems shoulda_and_friends jquery haml capify}

other_templates_list = Dir.new(default_template_path).entries.select do |entry|
  (entry != 'typical.rb') && 
  (/\.rb/.match(entry)) && 
  (!default_templates.include?(entry.split(".").first))
end.collect { |t| "'#{t.split('.').first}'" }.join(', ')

default_templates_list = default_templates.collect { |t| "'#{t}'" }.join(', ')

puts <<-MSG
**** TYPICAL RAILS INSTALL ****
* Loading templates: #{default_templates_list}
* Other templates: #{other_templates_list}
MSG

extra_templates = ask "Any other templates to load? (space separated)"

if extra_templates.blank?
  extra_templates = []
else
  extra_templates = extra_templates.split(" ")
end

(default_templates + extra_templates).each do |script|
  load_template File.join(DEFAULT_TEMPLATE_PATH, "#{script}.rb")
end

rake 'db:migrate'

message = 'typical.rb: Typical Rails setup complete.'

git :add => ".", :commit => "-m '#{message}'"

puts "***** #{message} *****"