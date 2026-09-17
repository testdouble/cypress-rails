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

  def test_that_transactional_server_is_on_by_default
    assert_equal(true, CypressRails::Config.new.transactional_server)
  end

  def test_that_transactional_server_can_be_turned_off
    mock_env("CYPRESS_RAILS_TRANSACTIONAL_SERVER" => "false") do
      assert_equal(false, CypressRails::Config.new.transactional_server)
    end
  end

  def test_that_server_threads_defaults_to_0_4
    assert_equal("0:4", CypressRails::Config.new.server_threads)
  end

  def test_that_server_threads_can_be_set_via_env
    mock_env("CYPRESS_RAILS_SERVER_THREADS" => "1:1") do
      assert_equal("1:1", CypressRails::Config.new.server_threads)
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
