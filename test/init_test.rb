require_relative "test_helper"
require "fileutils"
require "tmpdir"
require "cypress-rails/init"

class InitTest < Minitest::Test
  def setup
    @dir = Dir.mktmpdir
    @subject = CypressRails::Init.new
  end

  def teardown
    FileUtils.remove_entry(@dir)
  end

  def test_writes_cypress_config_js_when_no_config_file_exists
    @subject.call(@dir)

    assert(File.exist?(File.join(@dir, "cypress.config.js")))
  end

  CypressRails::Init::CONFIG_EXTENSIONS.each do |extension|
    define_method(:"test_skips_when_cypress_config_#{extension}_already_exists") do
      existing_path = File.join(@dir, "cypress.config.#{extension}")
      File.write(existing_path, "// existing config")

      @subject.call(@dir)

      assert_equal("// existing config", File.read(existing_path))
      refute(File.exist?(File.join(@dir, "cypress.config.js"))) unless extension == "js"
    end
  end
end
