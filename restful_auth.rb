# generate users / sessions?

if yes?("Generate users / sessions?")
  plugin 'restful_authentication', :git => 'git://github.com/technoweenie/restful-authentication.git', 
                                   :submodule => true
  generate("authenticated", "user session --include activation --stateful --rspec")                              
end