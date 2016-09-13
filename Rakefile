# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

# Create a new DB backup, and import it to the local Postgres DB
task :db do
  app = ENV["HEROKU_APP"] || "fastlane-refresher"
  db_name = ENV["DB_NAME"] || "refresher"

  puts "This script is going to drop your local database #{db_name} and fetch the database from heroku #{app}. Quit now if that doesn't sound good, or press any key to continue"
  STDIN.gets

  sh "heroku pg:backups capture --app #{app}"
  sh "curl -o latest.dump `heroku pg:backups public-url --app #{app}`"
  sh "dropdb #{db_name}"
  sh "createdb #{db_name}"
  sh "pg_restore --verbose --clean --no-acl --no-owner -h localhost -U krausefx -d #{db_name} latest.dump"
end
