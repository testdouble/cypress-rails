require_relative "finds_bin"
require_relative "config"
require_relative "initializer_hooks"
require_relative "manages_transactions"
require_relative "starts_rails_server"

module CypressRails
  class LaunchesCypress
    def initialize
      @initializer_hooks = InitializerHooks.instance
      @manages_transactions = ManagesTransactions.instance
      @starts_rails_server = StartsRailsServer.new
      @finds_bin = FindsBin.new
    end

    def call(command, config)
      puts config.to_s
      @initializer_hooks.run(:before_server_start)
      if config.transactional_server
        @manages_transactions.begin_transaction
      end
      @starts_rails_server.call(
        port: config.port,
        transactional_server: config.transactional_server
      )
      bin = @finds_bin.call(config.dir)
      at_exit do
        if config.transactional_server
          @manages_transactions.rollback_transaction
        end
        @initializer_hooks.run(:before_server_stop)
      end

      system <<~EXEC
        CYPRESS_BASE_URL=http://#{Capybara.server_host}:#{Capybara.server_port} #{bin} #{command} --project "#{config.dir}" #{config.cypress_cli_opts}
      EXEC
    end
  end
end
