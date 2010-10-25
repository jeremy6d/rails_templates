gem 'mongo_mapper'

db_name = ask('What should I call the database? ') || Dir.pwd.split("/").compact.last

file 'config/initializers/mongo_config.rb', <<-MONGOCONFIGRB
MongoMapper.database = "#{db_name}-\#{Rails.env}"
MONGOCONFIGRB

file 'config/database.yml', <<-CODE
# Using MongoDB
CODE

environment 'config.frameworks -= [:active_record]'