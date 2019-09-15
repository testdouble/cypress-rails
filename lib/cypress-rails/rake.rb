desc "Initialize cypress.json"
task :"cypress:init" do
  require "cypress-rails"
  CypressRails::Init.new.call
end
