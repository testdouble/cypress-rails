require_relative "configures_test_server"
require_relative "tracks_resets"

module CypressRails
  class StartsRailsServer
    def initialize
      @configures_test_server = ConfiguresTestServer.new
    end

    def call(port:, transactional_server:)
      @configures_test_server.call(port: port)
      configure_driver!
      configure_rails_to_run_our_state_reset_on_every_request!(transactional_server)
      Capybara.app = create_capybara_rack_app
      start_system_testing_server!
      Capybara.current_session
    end

    private

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
