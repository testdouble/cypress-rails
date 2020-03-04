# CHANGELOG

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
