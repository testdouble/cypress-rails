require_relative "configures_test_server"

module CypressRails
  class StartsRailsServer
    def initialize
      @configures_test_server = ConfiguresTestServer.new
    end

    def call(dir:, port:)
      @configures_test_server.call(port: port)

      require "action_dispatch/system_testing/driver"
      require "action_dispatch/system_testing/browser"
      ActionDispatch::SystemTesting::Driver.new(:selenium, {
        using: :headless_chrome,
        screen_size: [1400, 1400],
        options: {},
      }).use

      Capybara.app = Rack::Builder.new do
        map "/" do
          run Rails.application
        end
      end

      require "action_dispatch/system_testing/server"
      ActionDispatch::SystemTesting::Server.new.run

      Capybara.current_session
    end
  end
end
