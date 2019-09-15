module CypressRails
  class StartsRailsServer
    def call(dir:, port:)
      require "capybara"
      require "selenium-webdriver"
      Capybara.server_port = port || find_available_port
      Capybara.always_include_port = true

      Capybara.server = :puma, {Silent: false}

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

    private

    def find_available_port
      server = TCPServer.new(Capybara.server_host, 0)
      server.addr[1]
    ensure
      server&.close
    end
  end
end
