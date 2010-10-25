def default_template_path
  dirs = File.expand_path(__FILE__).split("/")
  dirs.pop
  File.join dirs
end