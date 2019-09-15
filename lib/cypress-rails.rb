require "cypress-rails/version"

module CypressRails
end

require "cypress-rails/init"
require "cypress-rails/railtie" if defined?(Rails)
