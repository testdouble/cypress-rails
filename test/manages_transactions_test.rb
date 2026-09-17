require_relative "test_helper"
require "active_record"
require "fileutils"
require "tmpdir"
require "cypress-rails/manages_transactions"

class ManagesTransactionsTest < Minitest::Test
  class Widget < ActiveRecord::Base
  end

  def setup
    @dir = Dir.mktmpdir
    ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: File.join(@dir, "test.sqlite3"))
    ActiveRecord::Base.connection_pool.with_connection do |connection|
      connection.create_table(:widgets) { |t| t.string :name }
    end
    @subject = CypressRails::ManagesTransactions.new
  end

  def teardown
    ActiveRecord::Base.remove_connection
    FileUtils.remove_entry(@dir)
  end

  def test_begin_transaction_shares_one_transaction_across_threads
    @subject.begin_transaction
    Widget.create!(name: "from the calling thread")

    assert_equal(true, on_another_thread(&:transaction_open?))
    assert_equal(1, on_another_thread { Widget.count })
  ensure
    @subject.rollback_transaction
  end

  def test_rollback_transaction_discards_writes_from_every_thread
    @subject.begin_transaction
    Widget.create!(name: "from the calling thread")
    on_another_thread { Widget.create!(name: "from another thread") }
    @subject.rollback_transaction

    assert_equal(0, Widget.count)
    assert_equal(false, on_another_thread(&:transaction_open?))
  end

  def test_rolls_back_writes_from_a_thread_holding_a_connection_before_the_transaction_began
    lease_connection_for_this_thread
    @subject.begin_transaction
    Widget.create!(name: "from the calling thread")
    @subject.rollback_transaction

    assert_equal(0, on_another_thread { Widget.count })
  end

  def test_stays_pinned_across_repeated_resets
    @subject.begin_transaction
    @subject.rollback_transaction
    @subject.begin_transaction

    assert_equal(true, on_another_thread(&:transaction_open?))
  ensure
    @subject.rollback_transaction
  end

  def test_errors_from_the_owner_thread_raise_in_the_caller
    assert_raises(StandardError) { @subject.rollback_transaction }
  end

  private

  def on_another_thread(&block)
    Thread.new {
      ActiveRecord::Base.connection_pool.with_connection do |connection|
        block.arity.zero? ? block.call : block.call(connection)
      end
    }.value
  end

  def lease_connection_for_this_thread
    if ActiveRecord::Base.respond_to?(:lease_connection)
      ActiveRecord::Base.lease_connection
    else
      ActiveRecord::Base.connection
    end
  end
end
