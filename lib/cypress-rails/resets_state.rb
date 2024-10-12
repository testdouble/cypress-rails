require_relative "config"
require_relative "manages_transactions"
require_relative "manages_transactions_before_rails72"
require_relative "initializer_hooks"

module CypressRails
  class ResetsState
    def initialize
      @manages_transactions = manages_transactions_instance
      @initializer_hooks = InitializerHooks.instance
    end

    def call(transactional_server:)
      if transactional_server
        @manages_transactions.rollback_transaction
        @manages_transactions.begin_transaction
      end
      @initializer_hooks.run(:after_state_reset)
    end

    private

    def manages_transactions_instance
      if Gem::Version.new(Rails.version) >= Gem::Version.new("7.2")
        ManagesTransactions.instance
      else
        ManagesTransactionsBeforeRails72.instance
      end
    end
  end
end
