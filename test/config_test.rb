require_relative "test_helper"

class ConfigTest < Minitest::Test
  def test_that_rails_dir_and_cypress_dir_use_default_directory
    config = CypressRails::Config.new
    expected_directory_path = Dir.pwd

    assert_equal(expected_directory_path, config.rails_dir)
    assert_equal(expected_directory_path, config.cypress_dir)
  end

  def test_that_rails_dir_and_cypress_dir_can_be_independently_set
    mock_env(
      "CYPRESS_RAILS_DIR" => "path/to/cypress-rails",
      "CYPRESS_RAILS_CYPRESS_DIR" => "path/to/another/cypress/directory"
    ) do
      config = CypressRails::Config.new

      assert_equal("path/to/cypress-rails", config.rails_dir)
      assert_equal("path/to/another/cypress/directory", config.cypress_dir)
    end
  end

  def test_that_cypress_dir_uses_same_directory_as_rails_dir_when_not_set
    mock_env("CYPRESS_RAILS_DIR" => "path/to/cypress-rails") do
      config = CypressRails::Config.new

      assert_nil(ENV["CYPRESS_RAILS_CYPRESS_DIR"])
      assert_equal("path/to/cypress-rails", config.cypress_dir)
    end
  end

  private

  def mock_env(partial_env_hash)
    old = ENV.to_hash
    ENV.update partial_env_hash
    begin
      yield
    ensure
      ENV.replace old
    end
  end
end
