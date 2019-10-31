require "pathname"
CLI = Pathname.new(File.dirname(__FILE__)).join("../../exe/cypress-rails")

desc "Initialize cypress.json"
task :"cypress:init" do
  system "#{CLI} init"
end

desc "Open interactive Cypress app for developing tests"
task :"cypress:open" do
  system "#{CLI} open"
end

desc "Run Cypress tests headlessly"
task :"cypress:run" do
  abort "Tests failed" unless system "#{CLI} run"
end
