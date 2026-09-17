require_relative "resets_state"
require_relative "server"

module CypressRails
  class StartsRailsServer
    def call(host:, port:, transactional_server:)
      app = create_rack_app(transactional_server)
      Server.new(app, host: host, port: port).tap do |server|
        server.boot
      end
    end

    def create_rack_app(transactional_server)
      Rack::Builder.new do
        map "/cypress_rails_reset_state" do
          run lambda { |env|
            begin
              ResetsState.new(transactional_server: transactional_server).call
              [200, {"content-type" => "text/plain"}, ["Reset"]]
            rescue => e
              warn e.full_message
              [500, {"content-type" => "text/plain"}, ["#{e.class}: #{e.message}"]]
            end
          }
        end
        map "/" do
          run Rails.application
        end
      end
    end
  end
end
