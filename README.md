# cypress-rails

This is a simple gem to make it easier to start writing browser tests with
[Cypress](http://cypress.io) for your Rails apps, regardless of whether your app
is server-side rendered HTML, completely client-side JavaScript, or something in
between.

## Installation

tl;dr:

1. Install the npm package `cypress`
2. Install this gem `cypress-rails`
3. Run `rake cypress:init`

### Installing Cypress itself

The first step is making sure Cypress is installed (that's up to you, this
library doesn't install Cypress, it just provides a little Rails specific glue).

If you're on newer versions of Rails and using
[webpacker](https://www.github.com/rails/webpacker) for your front-end assets,
then you're likely already using yarn to manage your JavaScript dependencies. If
that's the case, you can add Cypress with:

```
$ yarn add --dev cypress
```

If you're not using yarn in conjunction with your Rails app, check out the
Cypress docs on getting it installed. At the end of the day, this gem just needs
the `cypress` binary to exist someplace it can find.

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
$ bin/rake cypress:init
```

This will override a few configurations in your `cypress.json` configuration
file.


