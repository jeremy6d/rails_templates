gem "thoughtbot-clearance", :lib     => 'clearance',
                            :source  => 'http://gems.github.com',
                            :version => '0.7.0'

rake('gems:install', :sudo => true)
rake('gems:unpack')

generate :clearance