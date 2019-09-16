# cypress-rails

[![CircleCI](https://circleci.com/gh/testdouble/cypress-rails/tree/master.svg?style=svg)](https://circleci.com/gh/testdouble/cypress-rails/tree/master)

This is a simple gem to make it easier to start writing browser tests with
[Cypress](http://cypress.io) for your [Rails](https://rubyonrails.org) apps,
regardless of whether your app is server-side rendered HTML, completely
client-side JavaScript, or something in-between.

## Why do this?

Rails ships with a perfectly competent browser-testing facility called [system
tests](https://guides.rubyonrails.org/testing.html#system-testing) which depend
on [capybara](https://github.com/teamcapybara/capybara) to drive your tests,
most often with [Selenium](https://www.seleniumhq.org). All of these tools work,
are used by lots of people, and are a perfectly reasonable choice when writing
full-stack tests of your Rails application.

So why would you go off the Rails to use Cypress and this gem, adding two
additional layers to the Jenga tower of testing facilities that Rails ships
with? Really, it comes down to the potential for an improved development
experience. In particular:

* Cypress's [IDE-like `open`
  command](https://docs.cypress.io/guides/getting-started/writing-your-first-test.html#Add-a-test-file)
  provides a highly visual, interactive, inspectable test runner. Not only can
  you watch each test run and read the commands as they're executed, Cypress
  takes a DOM snapshot before and after each command, which makes rewinding and
  inspecting the state of the DOM trivially easy, something that I regularly
  find myself losing 20 minutes attempting to do with Capybara
* `cypress open` enables an almost REPL-like feedback loop that is much faster
  and more information dense than using Capybara and Selenium. Rather than
  running a test from the command line, seeing it fail, then adding a debug
  breakpoint to a test to try to manipulate the browser or tweaking a call to a
  Capybara API method, failures to be rather obvious when using Cypress and
  fixing it is usually as easy as tweaking a command, hitting save, and watching
  it re-run
* With very few exceptions, a Cypress test that works in a browser window will
  also pass when run headlessly in CI
* Cypress selectors are [just jQuery
  selectors](https://api.jquery.com/category/selectors/), which makes them both
  more familiar and more powerful than the CSS and XPath selectors offered by
  Capybara. Additionally, Cypress makes it very easy to drop into a plain
  synchronous JavaScript function for [making more complex
  assertions](https://docs.cypress.io/guides/references/assertions.html#Should-callback)
  or composing repetitive tasks into [custom
  commands](https://docs.cypress.io/api/cypress-api/custom-commands.html#Syntax#article)
* Cypress commands are, generally, much faster than analogous tasks in Selenium.
  Where certain clicks and form inputs will hang for 300-500ms for seemingly no
  reason when running against Selenium WebDriver, Cypress commands tend to run
  as fast as jQuery can select and fill an element (which is, of course, pretty
  fast)
* By default, Cypress [takes a
  video](https://docs.cypress.io/guides/guides/screenshots-and-videos.html#Screenshots#article)
  of every headless test run, taking a lot of the mystery (and subsequent
  analysis & debugging) out of test failures in CI

Nevertheless, there are trade-offs to attempting this (most notably around
Cypress's [limited browser
support](https://docs.cypress.io/guides/guides/launching-browsers.html#Browsers)
and the complications to test data management), and I wouldn't recommend
adopting Cypress and writing a bunch of browser tests for every application.
But, if the above points sound like solutions to problems you experience, you
might consider trying it out.

## Installation

**tl;dr**:

1. Install the npm package `cypress`
2. Install this gem `cypress-rails`
3. Run `rake cypress:init`

### Installing Cypress itself

The first step is making sure Cypress is installed (that's up to you, this
library doesn't install Cypress, it just provides a little Rails-specific glue).

If you're on newer versions of Rails and using
[webpacker](https://www.github.com/rails/webpacker) for your front-end assets,
then you're likely already using yarn to manage your JavaScript dependencies. If
that's the case, you can add Cypress with:

```
$ yarn add --dev cypress
```

If you're not using yarn in conjunction with your Rails app, check out the
Cypress docs on getting it installed. At the end of the day, this gem just needs
the `cypress` binary to exist either in `./node_modules/.bin/cypress` or on your
`PATH`.

### Installing the cypress-rails gem

Now, to install the cypress-rails gem, you'll want to add it to your development
& test gem groups of your Gemfile, so that you have easy access to its rake
tasks:

``` ruby
group :development, :test do
  gem "cypress-rails"
end
```

Once installed, you'll want to run:

```
$ rake cypress:init
```

This will override a few configurations in your `cypress.json` configuration
file.

## Usage

### Develop tests interactively with `cypress open`

When writing tests with Cypress, you'll find the most pleasant experience (by
way of a faster feedback loop and an interactive, easy-to-inspect test runner)
using the `cypress open` command.

When using Rails, however, you'll also want your Rails test server to be running
so that there's something for Cypress to interact with. `cypress-rails` provides
a wrapper for running `cypress open` with a dedicated Rails test server.

So, by running either:

```
$ cypress-rails open
```

Or, if you don't mind the extra cost of loading rake just so it can call
`system`:

```
$ rake cypress:open
```

Add tests to `cypress/integration`. Simply click a test file in the Cypress
application window to launch the test in a browser. Each time you save the test
file, it will re-run itself.

### Run tests headlessly with `cypress run`

To run your tests headlessly (e.g. when you're in CI), you'll want the `run`
command

```
$ cypress-rails run
```

Or, with rake:

```
$ rake cypress:run
```

### Write Ruby tests that wrap and invoke your cypress tests

You can also extend a provided `CypressRails::TestCase`, which itself inherits
from Rails' built-in `ActionDispatch::SystemTestCase`.

That means you can add a test named `test/system/cypress_test.rb`:

```ruby
require "test_helper"

class CypressTest < CypressRails::TestCase
  test_locator "cypress/integration/**/*.js"
end
```

And it will run alongside all the rest of your system tests. Because this would
be invoked by your existing test scripts, you can benefit from whatever custom
test helpers (e.g. database setup, test coverage, etc.) your other full-stack
tests need, as well as specifying custom `setup` and `teardown` directives.

Each Cypress file matched by the `test_locator` is translated to a single test
case, which—while slightly inefficient, as it spools Cypress up and down
multiple times—also makes it easy to handle each Cypress file as you would any
other Ruby test. It also allows for CLI usage like this (where the test name is
an expansion of the file location with the path separators replaced with `_`):

```
$ bin/rails test test/system --name test_cypress_integration_send_invoice_js
```

**WARNING**: keep in mind that any custom Ruby code you add before or after each
Cypress test is run in the context of a `CypressRails::TestCase` will _not_ be
run when developing with `cypress open`! That means this is probably not the
most rock-solid strategy for consistent test behavior when it comes to things
like test data management.

### Setting up continuous integration

#### Circle CI

Nowadays, Cypress and Circle get along pretty well without much customization.
The only tricky bit is that Cypress will install its large-ish binary to
`~/.cache/Cypress`, so if you cache your dependencies, you'll want to include
that path:

```yml
version: 2
jobs:
  build:
    docker:
      - image: circleci/ruby:2.6-node-browsers
      - image: circleci/postgres:9.4.12-alpine
        environment:
          POSTGRES_USER: circleci
    steps:
      - checkout

      # Bundle install dependencies
      - type: cache-restore
        key: v1-gems-{{ checksum "Gemfile.lock" }}

      - run: bundle install --path vendor/bundle

      - type: cache-save
        key: v1-gems-{{ checksum "Gemfile.lock" }}
        paths:
          - vendor/bundle

      # Yarn dependencies
      - restore_cache:
          keys:
            - v1-yarn-{{ checksum "package.json" }}
            # fallback to using the latest cache if no exact match is found
            - v1-yarn-

      - run: yarn install

      - save_cache:
          paths:
            - node_modules
            - ~/.cache
          key: v1-yarn-{{ checksum "package.json" }}

      # Run your cypress tests
      - run: bin/rake cypress:run
```

## Configuration

You can change the behavior of this gem by setting these environment variables:

* **RAILS_CYPRESS_PORT**: the port to run the Rails test server on (defaults to
  a random available port
