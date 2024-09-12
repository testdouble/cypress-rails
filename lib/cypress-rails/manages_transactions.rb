require_relative "initializer_hooks"

module CypressRails
  class ManagesTransactions
    def self.instance
      @instance ||= new
    end

    def begin_transaction
      @connections = gather_connections
      @connections.each do |connection|
        connection.begin_transaction joinable: false, _lazy: false
        if connection.pool.respond_to?(:pin_connection!)
          # Rails 7.2+
          connection.pool.pin_connection!(true)
        else
          connection.pool.lock_thread = true
        end
      end

      # When connections are established in the future, begin a transaction too
      @connection_subscriber = ActiveSupport::Notifications.subscribe("!connection.active_record") { |_, _, _, _, payload|
        if payload.key?(:spec_name) && (spec_name = payload[:spec_name])
          setup_shared_connection_pool

          begin
            connection = ActiveRecord::Base.connection_handler.retrieve_connection(spec_name)
          rescue ActiveRecord::ConnectionNotEstablished
            connection = nil
          end

          if connection && !@connections.include?(connection)
            connection.begin_transaction joinable: false, _lazy: false
            if connection.pool.respond_to?(:pin_connection!)
              # Rails 7.2+
              connection.pool.pin_connection!(true)
            else
              connection.pool.lock_thread = true
            end
            @connections << connection
          end
        end
      }

      @initializer_hooks.run(:after_transaction_start)
    end

    def rollback_transaction
      return unless @connections.present?

      ActiveSupport::Notifications.unsubscribe(@connection_subscriber) if @connection_subscriber

      @connections.each do |connection|
        connection.rollback_transaction if connection.transaction_open?
        if connection.pool.respond_to?(:unpin_connection!)
          # Rails 7.2+
          connection.pool.unpin_connection!
        else
          connection.pool.lock_thread = false
        end
      end
      @connections.clear

      ActiveRecord::Base.connection_handler.clear_active_connections!
    end

    private

    def initialize
      @initializer_hooks = InitializerHooks.instance
    end

    def gather_connections
      setup_shared_connection_pool

      ActiveRecord::Base.connection_handler.connection_pool_list.map do |pool|
        # Rails 7.2+
        if pool.respond_to?(:lease_connection)
          pool.lease_connection
        else
          pool.connection
        end
      end
    end

    # Shares the writing connection pool with connections on
    # other handlers.
    #
    # In an application with a primary and replica the test fixtures
    # need to share a connection pool so that the reading connection
    # can see data in the open transaction on the writing connection.
    def setup_shared_connection_pool
      return unless ActiveRecord::TestFixtures.respond_to?(:setup_shared_connection_pool)
      @legacy_saved_pool_configs ||= Hash.new { |hash, key| hash[key] = {} }
      @saved_pool_configs ||= Hash.new { |hash, key| hash[key] = {} }

      ActiveRecord::TestFixtures.instance_method(:setup_shared_connection_pool).bind(self).call
    end
  end
end
