require_relative "tracks_resets"
require_relative "server"

module CypressRails
  class StartsRailsServer
    def call(port:, transactional_server:)
      configure_rails_to_run_our_state_reset_on_every_request!(transactional_server)
      app = create_capybara_rack_app
      Server.new(app, port: port).tap do |server|
        server.boot
      end

      ## -- old>
      # require "capybara"
      # require "selenium-webdriver"
      # Capybara.server_port = port || find_available_port
      # Capybara.always_include_port = true
      # Capybara.server = :puma, {Silent: false}
      # Capybara.current_session

      # configure_driver!
      # configure_rails_to_run_our_state_reset_on_every_request!(transactional_server)
      # Capybara.app = create_capybara_rack_app
      # start_system_testing_server!
      # Capybara.current_session
    end

    private

    def find_available_port(host)
      server = TCPServer.new(host, 0)
      port = server.addr[1]
      server.close

      # Workaround issue where some platforms (mac, ???) when passed a host
      # of '0.0.0.0' will return a port that is only available on one of the
      # ip addresses that resolves to, but the next binding to that port requires
      # that port to be available on all ips
      server = TCPServer.new(host, port)
      port
    rescue Errno::EADDRINUSE
      retry
    ensure
      server&.close
    end

    def configure_driver!
      # this is only necessary b/c we're piggybacking on the capybara server
      Selenium::WebDriver::Chrome::Service.driver_path.try(:call)

      Capybara.register_driver :selenium do |app|
        options = Selenium::WebDriver::Chrome::Options.new
        options.args << "--headless"
        options.args << "--disable-gpu" if Gem.win_platform?

        Capybara::Selenium::Driver.new(app, browser: :chrome, options: options).tap do |driver|
          driver.browser.manage.window.size = Selenium::WebDriver::Dimension.new(1400, 1400)
        end
      end
      Capybara.current_driver = :selenium
    end

    def configure_rails_to_run_our_state_reset_on_every_request!(transactional_server)
      Rails.application.executor.to_run do
        TracksResets.instance.reset_state_if_needed(transactional_server)
      end
    end

    def create_capybara_rack_app
      Rack::Builder.new do
        map "/cypress_rails_reset_state" do
          run lambda { |env|
            TracksResets.instance.reset_needed!
            [202, {"Content-Type" => "text/plain"}, ["Accepted"]]
          }
        end
        map "/" do
          run Rails.application
        end
      end
    end

    def start_system_testing_server!
      Capybara.server = :puma, {Silent: false} if Capybara.server == Capybara.servers[:default]
      Capybara.always_include_port = true
    end
  end
end
