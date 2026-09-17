module CypressRails
  class ManagesTransactions
    def self.instance
      @instance ||= new
    end

    module MinitestLifecycle
      def before_setup
      end

      def after_teardown
      end
    end

    def begin_transaction
      return unless defined?(ActiveRecord::TestFixtures)

      # A connection this thread already holds wouldn't be the pinned one
      release_connections_held_by_this_thread
      on_owner_thread { fixtures.before_setup }
    end

    def rollback_transaction
      return unless defined?(ActiveRecord::TestFixtures)

      begin
        on_owner_thread { fixtures.after_teardown }
      ensure
        release_connections_held_by_this_thread
      end
    end

    private

    def initialize
      @jobs = Queue.new
      # Rails 7.1 keys a pinned connection to the thread that pinned it, and a
      # Puma thread's end-of-request cleanup would check it back in, so a
      # dedicated thread that never serves requests owns the transaction.
      @owner = Thread.new do
        loop do
          job, result = @jobs.pop
          begin
            result << [:ok, job.call]
          rescue Exception => e # standard:disable Lint/RescueException
            result << [:error, e]
          end
        end
      end
    end

    def on_owner_thread(&job)
      result = Queue.new
      @jobs << [job, result]
      status, value = result.pop
      raise value if status == :error
      value
    end

    def release_connections_held_by_this_thread
      ActiveRecord::Base.connection_handler.clear_active_connections!(:all)
    end

    def fixtures
      @fixtures ||= Class.new {
        # Must be included before TestFixtures, or its hooks never run
        include MinitestLifecycle
        include ActiveRecord::TestFixtures

        def name
          "cypress-rails"
        end
      }.new
    end
  end
end
