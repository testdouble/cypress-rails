require_relative "config"
require_relative "initializer_hooks"
require_relative "manages_transactions"

module CypressRails
  class ResetsState
    LOCK = Mutex.new

    def initialize(
      transactional_server:,
      manages_transactions: nil,
      initializer_hooks: InitializerHooks.instance,
      wrap: ->(&block) { Rails.application.reloader.wrap(&block) }
    )
      @transactional_server = transactional_server
      @manages_transactions = manages_transactions
      @initializer_hooks = initializer_hooks
      @wrap = wrap
    end

    def call
      LOCK.synchronize do
        if @transactional_server
          # Outside the reloader: waiting on the owner thread while holding a
          # reloader share could deadlock against a code reload
          manages_transactions.rollback_transaction
          manages_transactions.begin_transaction
        end

        @wrap.call do
          @initializer_hooks.run(:after_transaction_start) if @transactional_server
          @initializer_hooks.run(:after_state_reset)
        end
      end
    end

    private

    def manages_transactions
      @manages_transactions ||= ManagesTransactions.instance
    end
  end
end
