require "cypress-rails/version"

module CypressRails
end

require "cypress-rails/init"
require "cypress-rails/open"
require "cypress-rails/run"
require "cypress-rails/test_case"
require "cypress-rails/railtie" if defined?(Rails)
