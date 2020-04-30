# CHANGELOG

## 0.2.0

* If `RAILS_ENV` has been explicitly set when the CLI or rake task is run,
respect that set value instead of overriding it to "test"

## 0.1.3

* Improve behavior of SIGINT (Ctrl-C) so a traceback isn't printed and stdout
  isn't flushed after the program exits

## 0.1.2

* Drop the hard deps on capybara and selenium-webdrivers (instead inlining
  portions of the Capybara server logic). Additionally, add a hard dep on puma
  since this gem is useless without it

## 0.1.1

* Fix the `before_server_stop` hook by rolling back transactions first so that
  it can clean out test data

## 0.1.0

* **[Breaking]** Remove `CypressRails::TestCase`. Use `rake cypress:run` instead
* **[Breaking]** cypress-rails now starts a transaction immediately after
  launching the server, which could result in other processes not being able
  to observe your changes. To revert to the old behavior, set the env var
  `CYPRESS_RAILS_TRANSACTIONAL_SERVER=false`
* Add configuration variables `CYPRESS_RAILS_DIR`,
  `CYPRESS_RAILS_TRANSACTIONAL_SERVER`. Rename port and Cypress CLI forwarding
  to `CYPRESS_RAILS_PORT` and `CYPRESS_RAILS_CYPRESS_OPTS`
* Add test data configuration hooks (to be run in an initializer):
  * `CypressRails.hooks.before_server_start`
  * `CypressRails.hooks.after_transaction_start`
  * `CypressRails.hooks.after_state_reset` - after a transaction rollback
  * `CypressRails.hooks.before_server_stop` - called in an `at_exit` hook

## 0.0.4

* Started a changelog
