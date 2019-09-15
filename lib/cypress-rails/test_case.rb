require_relative "configures_test_server"

module CypressRails
  class TestCase < ActionDispatch::SystemTestCase
    driven_by :selenium_headless

    def setup
      @@__cypress_rails_configures_test_server ||= ConfiguresTestServer.new.call
    ensure
      super
    end

    def self.test_locator(path_or_globs)
      Dir[path_or_globs].map do |path|
        test_name = "test_#{path.gsub(/[\/\.:\\]/, "_")}"
        define_method test_name do
          bin = FindsBin.new.call
          command = "CYPRESS_BASE_URL=http://#{Capybara.server_host}:#{Capybara.server_port} #{bin} run --spec \"#{path}\""
          unless system(command)
            raise <<~ERROR
              Cypress test failed. Try again with:
                $ rails test test/system --name #{test_name}

              Underlying Cypress command run was:
                $ #{command}
            ERROR
          end
        end
      end
    end
  end
end
