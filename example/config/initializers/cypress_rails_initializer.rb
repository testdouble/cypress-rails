return unless Rails.env.test?
require "./lib/external_service"
require "database_cleaner/active_record"

Rails.application.load_tasks unless defined?(Rake::Task)

def seed_compliments!
  Compliment.create!(text: "You are courageous")
end

CypressRails.hooks.before_server_start do
  # Loaded before the transaction starts, so these persist across resets
  Rake::Task["db:fixtures:load"].invoke
end

CypressRails.hooks.after_server_start do
  ExternalService.start_service
end

if CypressRails::Config.new.transactional_server
  CypressRails.hooks.after_transaction_start do
    # Runs inside the transaction at launch and after every reset, so it's
    # rolled back each time
    seed_compliments!
  end
else
  CypressRails.hooks.after_state_reset do
    # Without the transactional server, the app rebuilds its own data.
    # clean_with uses a fresh truncation strategy on every call, and
    # reset_cache stops the fixtures from being skipped as already loaded.
    DatabaseCleaner[:active_record].clean_with(:truncation)
    ActiveRecord::FixtureSet.reset_cache
    ActiveRecord::FixtureSet.create_fixtures(Rails.root.join("test/fixtures"), ["compliments"])
    seed_compliments!
  end
end

CypressRails.hooks.after_state_reset do
  if Compliment.count != 4
    raise "Wait I was expecting exactly 4 compliments!"
  end
end

CypressRails.hooks.before_server_stop do
  ExternalService.stop_service
  # Purge and reload the test database so we don't leave our fixtures in there
  Rake::Task["db:test:prepare"].invoke
end
