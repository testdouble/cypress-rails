require "bundler/gem_tasks"
require "rake/testtask"
require "standard/rake"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

desc "run cypress tests in an example app"
task :test_example_app do
  sh "script/test_example_app"
end

task default: [:test, "standard:fix", :test_example_app]
