desc "Initialize cypress.json"
task :"cypress:init" do
  require "cypress-rails"
  CypressRails::Init.new.call
end

desc "Open interactive Cypress app for developing tests"
task "cypress:open": [:environment] do
  require "cypress-rails"
  CypressRails::Open.new.call
end
