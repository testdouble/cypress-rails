# README

The example app has multiple, symlinked Gemfiles to be able to test against
different dependency versions (so far just Rails).

For the latest version of Rails, you can just use all the default `bundle`
commands:
```
bundle
bundle exec rake cypress:run
```

For previous version(s) of Rails, you need to specify the Gemfile to use. So
for `Gemfile_rails71` (which uses Rails 7.1), you'll need to include an env var
when you use `bundle` commands:
```
BUNDLE_GEMFILE=Gemfile_rails71 bundle
BUNDLE_GEMFILE=Gemfile_rails71 bundle exec rake cypress:run
```
