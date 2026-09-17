# CHANGELOG

## 0.9.1

* Add `CYPRESS_RAILS_SERVER_THREADS` (default: `"0:4"`) to configure the min:max
  thread count passed to Puma's `Threads:` option, so you can e.g. set it to
  `"1:1"` for single-threaded mode.

## 0.9.0

* **[Breaking]** Require Rails 7.1 or newer
* **[Breaking]** (relative to 0.8.0) Rename `after_reset_requested` back to
  `after_state_reset`, and restore the transactional server as the default
  behavior
* Bring back the transactional server (and `CYPRESS_RAILS_TRANSACTIONAL_SERVER`),
  which 0.8.0 had removed. It didn't work reliably to have apps reset their own
  state under cypress-rails' multi-threaded Puma server
* `/cypress_rails_reset_state` now resets before responding (returning `200`
  instead of `202`), rather than deferring the reset to the next request

See [docs/changes-in-0.9.0.md](docs/changes-in-0.9.0.md) for a full comparison
with both 0.7.1 and 0.8.0.

## 0.8.0

(Avoid this version due to issues with resetting data during threaded requests.
0.9.0 is almost entirely compatible with 0.7.1 while still bringing Rails 7.2+
compatibility, so the breaking changes in this version are for nothing.)

* **[Breaking]** Remove `CYPRESS_RAILS_TRANSACTIONAL_SERVER`. cypress-rails no
  longer wraps the server in a transaction or resets it between tests -
  automatic Rails-version-specific transaction management proved unsustainable
  to maintain (see [#164](https://github.com/testdouble/cypress-rails/issues/164),
  [#161](https://github.com/testdouble/cypress-rails/issues/161)). Apps must
  now reset their own state (e.g. with `database_cleaner`) using the
  `after_reset_requested` hook; see the example app for a working setup
* **[Breaking]** Remove the `after_transaction_start` hook, since cypress-rails
  no longer manages transactions
* **[Breaking]** Rename the `after_state_reset` hook to `after_reset_requested`.
  It now fires whenever a reset was requested (via hitting
  `/cypress_rails_reset_state`), rather than after cypress-rails had already
  performed one - the app is expected to perform the reset itself in this hook
* **[Breaking]** Remove `CypressRails::Config#transactional_server`
* Add Rails 7.2 / 8.0 support

## 0.7.1
* Add Rack 3.1 support [#163](https://github.com/testdouble/cypress-rails/pull/163)

## 0.7.0
* Add a `CYPRESS_RAILS_CYPRESS_DIR` option for cases where
the cypress tests live outside the CYPRESS_RAILS_DIR [#159](https://github.com/testdouble/cypress-rails/pull/159)

## 0.6.1

* Fix a deprecation warning in Rails
  [#157](https://github.com/testdouble/cypress-rails/pull/157)

## 0.6.0

* Update initializer task to generate valid Cypress v10+ configurations
  [#156](https://github.com/testdouble/cypress-rails/pull/156)

## 0.5.5

* Add Puma 6 support
  [#136](https://github.com/testdouble/cypress-rails/pull/136)

## 0.5.4

* Fix Rails 5 support
  [#126](https://github.com/testdouble/cypress-rails/pull/126)

## 0.5.3

* Fix 2.5 & 2.6 compatibility
  [#100](https://github.com/testdouble/cypress-rails/issues/100)

## 0.5.2

* Fixes a puma deprecation warning
  [#95](https://github.com/testdouble/cypress-rails/pull/95)

## 0.5.1

* Sprinkles two instance variables to the custom transaction manager that cribs
  its implementation from ActiveRecord::TestFixtures (see f75f280)
  [#88](https://github.com/testdouble/cypress-rails/issues/88)
  [#89](https://github.com/testdouble/cypress-rails/pull/89)

## 0.5.0

* Add hook `after_server_start`
  [#63](https://github.com/testdouble/cypress-rails/pull/63)
* Fix namespace bug
  [#64](https://github.com/testdouble/cypress-rails/pull/64)

## 0.4.2

* Add support to Rails 6.1 ([#52](https://github.com/testdouble/cypress-rails/issue/52))

## 0.4.1

* Add backcompat for Ruby 2.4
  ([#47](https://github.com/testdouble/cypress-rails/pull/47))

## 0.4.0

* Add a `CYPRESS_RAILS_HOST` option that allows a hostname to be specified (as
opposed to 127.0.0.1). Puma will still bind to 127.0.0.1, but Cypress will use
the hostname in its `baseUrl`, which may be necessary for some folks' tests to
work

## 0.3.0

* Add a `CYPRESS_RAILS_BASE_PATH` option which will be appended to the
  `CYPRESS_BASE_URL` option that cypress-rails sets when launching cypress
  commands. Apps that set `baseUrl` to something other than "/" can set this env
  var to match for consistent behavior (or else set it using Cypress.config in a
  support file)

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
