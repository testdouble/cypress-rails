return unless Rails.env.test?
require "./lib/external_service"
require "database_cleaner/active_record"

Rails.application.load_tasks unless defined?(Rake::Task)

DatabaseCleaner.strategy = :transaction

def seed_compliments!
  # After each resettable transaction starts, add this compliment (it will
  # be rolled back on the next reset)
  Compliment.create(text: "You are courageous")
end

CypressRails.hooks.before_server_start do
  # Add our fixtures before the resettable transaction is started
  Rake::Task["db:fixtures:load"].invoke

  DatabaseCleaner.start
  seed_compliments!
end

CypressRails.hooks.after_server_start do
  # Start up external service
  ExternalService.start_service
end

CypressRails.hooks.after_reset_requested do
  DatabaseCleaner.clean
  DatabaseCleaner.start
  seed_compliments!

  if Compliment.count != 4
    raise "Wait I was expecting exactly 4 compliments!"
  end
end

CypressRails.hooks.before_server_stop do
  DatabaseCleaner.clean
  ExternalService.stop_service
  # Purge and reload the test database so we don't leave our fixtures in there
  Rake::Task["db:test:prepare"].invoke
end
