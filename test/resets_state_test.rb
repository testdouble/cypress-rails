require_relative "test_helper"
require "timeout"
require "cypress-rails/resets_state"

class ResetsStateTest < Minitest::Test
  class FakeTransactions
    def initialize(calls)
      @calls = calls
    end

    def begin_transaction
      @calls << :begin_transaction
    end

    def rollback_transaction
      @calls << :rollback_transaction
    end
  end

  def setup
    @calls = []
    @hooks = CypressRails::InitializerHooks.instance
    @hooks.reset!
  end

  def teardown
    @hooks.reset!
  end

  def test_transactional_reset_rolls_back_and_begins_before_running_hooks
    @hooks.after_transaction_start { @calls << :after_transaction_start }
    @hooks.after_state_reset { @calls << :after_state_reset }

    resets_state(transactional_server: true).call

    assert_equal(
      [:rollback_transaction, :begin_transaction, :wrap_start, :after_transaction_start, :after_state_reset, :wrap_end],
      @calls
    )
  end

  def test_non_transactional_reset_only_runs_after_state_reset
    @hooks.after_transaction_start { @calls << :after_transaction_start }
    @hooks.after_state_reset { @calls << :after_state_reset }

    resets_state(transactional_server: false).call

    assert_equal([:wrap_start, :after_state_reset, :wrap_end], @calls)
  end

  def test_concurrent_resets_run_one_at_a_time
    entered = Queue.new
    release = Queue.new
    @hooks.after_state_reset do
      entered << true
      release.pop
    end

    first = Thread.new { resets_state(transactional_server: false).call }
    Timeout.timeout(2) { entered.pop }
    second = Thread.new { resets_state(transactional_server: false).call }

    assert_nil(second.join(0.1))
    assert_empty(entered)

    release << true
    Timeout.timeout(2) { entered.pop }
    release << true
    Timeout.timeout(2) { [first, second].each(&:join) }
  ensure
    2.times { release << true }
  end

  def test_a_raising_hook_releases_the_lock
    @hooks.after_state_reset { raise "boom" }
    assert_raises(RuntimeError) { resets_state(transactional_server: false).call }

    @hooks.reset!
    @hooks.after_state_reset { @calls << :after_state_reset }
    Timeout.timeout(2) { resets_state(transactional_server: false).call }

    assert_includes(@calls, :after_state_reset)
  end

  private

  def resets_state(transactional_server:)
    CypressRails::ResetsState.new(
      transactional_server: transactional_server,
      manages_transactions: FakeTransactions.new(@calls),
      initializer_hooks: @hooks,
      wrap: ->(&block) {
        @calls << :wrap_start
        block.call
        @calls << :wrap_end
      }
    )
  end
end
