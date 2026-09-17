# Changes in cypress-rails 0.9.0

cypress-rails 0.8.0 removed the transactional server and told apps to reset
their own database state. That didn't work reliably under cypress-rails'
multi-threaded Puma server, so 0.9.0 brings the transactional server back.

This document compares 0.9.0 with both 0.7.1 (the last release with the
transactional server) and 0.8.0.

## Relative to 0.7.1

For an app on Rails 7.1 or newer, upgrading from 0.7.1 to 0.9.0 is effectively
non-breaking. The public API is restored exactly as it was in 0.7.1:

- `CYPRESS_RAILS_TRANSACTIONAL_SERVER` (default `true`) and
  `CypressRails::Config#transactional_server`
- All five hooks, with their 0.7.1 names: `before_server_start`,
  `after_server_start`, `after_transaction_start`, `after_state_reset`, and
  `before_server_stop`
- The hook order: `after_transaction_start` runs right after the transaction
  begins, both at launch and on each reset, before `after_state_reset`

The differences are below.

### 1. Rails 7.1 or newer is required (breaking)

The gemspec's `railties` requirement goes from `>= 5.2.0` to `>= 7.1`, so apps
on Rails 5.2 through 7.0 need to stay on 0.7.1.

In the other direction, 0.9.0 supports Rails 7.2, 8.0, and 8.1, where 0.7.1's
transactional server crashed
([#164](https://github.com/testdouble/cypress-rails/issues/164)).

### 2. `/cypress_rails_reset_state` resets before responding (behavior change)

In 0.7.1, hitting `/cypress_rails_reset_state` returned `202 Accepted`
immediately, and the rollback and `after_state_reset` hooks ran at the
beginning of the next request the Rails app received. In 0.9.0:

- The rollback and hooks run before `/cypress_rails_reset_state` responds, and
  it returns `200` instead of `202`.
- If a hook raises, that request returns a `500` with the error class and
  message.
- The hooks run in the reset request's own thread, inside
  `Rails.application.reloader.wrap`, instead of inside whichever request came
  next.

For the documented usage,
`beforeEach(() => cy.request('/cypress_rails_reset_state'))`, the result is the
same, just more reliable. The only things this would break are a test that
asserts the `202` status, or one that depends on the reset being deferred until
a later request.

#### Why the reset is synchronous now

This change isn't what fixed 0.8.0's flaky resets; bringing back the pinned
transaction did. It stands on its own for three reasons.

**A failing hook no longer cascades into every later test.** In 0.7.1, if
`after_state_reset` raised, the failure landed on whatever request came next,
usually the test's `cy.visit`, as a generic 500 page. The "reset needed" flag
was only cleared after the hooks succeeded, so it stayed set: every later
request re-ran the failing hook and returned a 500, and one broken hook failed
the rest of the suite with symptoms far from the cause. Now the `cy.request`
that asked for the reset fails, showing the exception, and the next reset
starts clean.

**Concurrent requests can't race the reset.** With next-request semantics,
every request through Rails checked an unsynchronized flag. When a page load
fires several requests through Rails at once (XHR on load, Turbo frames,
ActiveStorage images), whichever one ran first did the reset, and nothing made
the others wait. One could read the database mid-reset, after the rollback but
before `after_transaction_start` reseeded it, or two could both run the reset.
Now the reset happens alone in its own request, one reset at a time, and
Cypress waits for it to finish before the test's next command, so the test's
own requests can't overlap it.

**Reset work stays out of the app's requests.** 0.7.1 installed a hook on every
request in the app and did the reset inside whichever request came next: inside
its logging, its timing, its thread-local state, and with any exception
attributed to it. Now the reset is its own request, and no other request pays
for it.

The reason for the old design no longer applies. It was introduced together
with the transactional server so that the rollback would run on a request
thread inside Rails' executor, where the pinned connection lived. In 0.9.0 a
dedicated thread owns the transaction, so there's no reason to defer the reset
to the next request.

`200` replaces `202` because `202 Accepted` means "received, will be processed
later", which is no longer true.

### 3. `after_server_start` runs once (bug fix)

`after_server_start` hooks now run exactly once, after the server is responding
([#186](https://github.com/testdouble/cypress-rails/issues/186)). Before, they
ran once per 0.1-second boot poll: several times on a slow boot, and in
principle not at all if the server responded on the first check. The hooks
still finish before Cypress launches. Hooks that are slow also no longer count
against the 60-second boot timeout.

## Relative to 0.8.0

0.9.0 undoes 0.8.0's breaking changes, which makes it breaking for apps that
adopted 0.8.0:

- **The hook is `after_state_reset` again.** `after_reset_requested` has been
  removed without an alias, so an initializer that calls
  `CypressRails.hooks.after_reset_requested` raises `NoMethodError` at boot.
- **The transactional server is back and on by default.** An app following
  0.8.0's README, with database_cleaner resetting data in
  `after_reset_requested`, should remove that setup and rely on the transaction.
  An app that needs real concurrent database access in its tests can set
  `CYPRESS_RAILS_TRANSACTIONAL_SERVER=false` instead, and reset data with a
  truncation-based approach. The README describes that pattern and its
  tradeoffs.
- **Rails 7.1 or newer is required**, as described above.
- **`/cypress_rails_reset_state` resets before responding**, as described above.
  0.8.0 also deferred the reset to the next request.

## Changelog notes

Worth listing in the 0.9.0 changelog:

- The Rails 7.1 minimum, marked as breaking.
- The synchronous reset endpoint, marked as a behavior change rather than a
  breaking one.
- The 0.8.0 reversals, marked as breaking relative to 0.8.0.
