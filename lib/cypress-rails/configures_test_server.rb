module CypressRails
  class ConfiguresTestServer
    def call(port:)
      require "capybara"
      require "selenium-webdriver"
      Capybara.server_port = port || find_available_port
      Capybara.always_include_port = true
      Capybara.server = :puma, {Silent: false}
      Capybara.current_session

      true
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
