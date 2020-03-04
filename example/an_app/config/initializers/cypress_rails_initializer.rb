return unless Rails.env.test?

require "cypress-rails"

CypressRails.hooks.before_server_start do
  # Add our fixtures before the resettable transaction is started
  Rails.application.load_tasks
  Rake::Task["db:test:prepare"].invoke
  Rake::Task["db:fixtures:load"].invoke
end

CypressRails.hooks.after_transaction_start do
  # After each transaction, add this compliment (will be rolled back on reset)
  Compliment.create(text: "You are courageous")
end

CypressRails.hooks.after_state_reset do
  if Compliment.count != 4
    raise "Wait I was expecting exactly 4 compliments!"
  end
end

CypressRails.hooks.before_server_stop do
  # Purge and reload the test database so we don't leave our fixtures in there
  Rails.application.load_tasks
  Rake::Task["db:test:prepare"].invoke
end
