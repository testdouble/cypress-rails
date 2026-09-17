require_relative "test_helper"
require "timeout"
require "cypress-rails/server"

class ServerTest < Minitest::Test
  # Starts a real Puma, optionally after a delay, so boot has to poll for it
  class SlowPuma
    attr_reader :threads

    def initialize(delay: 0)
      @delay = delay
      @threads = []
    end

    def create(app, port, host)
      @threads << Thread.current
      sleep @delay
      CypressRails::Server::Puma.create(app, port, host)
    end
  end

  def setup
    @hooks = CypressRails::InitializerHooks.instance
    @hooks.reset!
    @pumas = []
    @calls = 0
    @hooks.after_server_start { @calls += 1 }
  end

  def teardown
    @hooks.reset!
    @pumas.flat_map(&:threads).each(&:kill)
  end

  def test_after_server_start_runs_once_when_the_server_responds_right_away
    boot

    assert_equal(1, @calls)
  end

  def test_after_server_start_runs_once_when_the_server_takes_a_while
    boot(delay: 0.5)

    assert_equal(1, @calls)
  end

  def test_after_server_start_only_runs_once_the_server_is_responding
    responsive = []
    server = build_server(delay: 0.5)
    @hooks.after_server_start { responsive << server.responsive? }

    Timeout.timeout(10) { server.boot }

    assert_equal([true], responsive)
  end

  def test_after_server_start_does_not_run_again_when_boot_is_called_twice
    server = boot
    server.boot

    assert_equal(1, @calls)
  end

  private

  def boot(delay: 0)
    build_server(delay: delay).tap do |server|
      Timeout.timeout(10) { server.boot }
    end
  end

  def build_server(delay: 0)
    puma = SlowPuma.new(delay: delay)
    @pumas << puma

    CypressRails::Server.new(
      # A new app per server, since the port is cached by app object id
      ->(env) { [200, {"content-type" => "text/plain"}, ["ok"]] },
      host: "127.0.0.1",
      port: nil,
      initializer_hooks: @hooks,
      puma: puma
    )
  end
end
