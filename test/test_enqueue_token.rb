require 'minitest/autorun'
require 'queue_it_token'

class EnqueueTokenTest < Minitest::Test
  def test_simple_usage
    enqueue_token = EnqueueToken.new(
      customer_id: 'ticketania'
    )

    assert_equal 'ticketania', enqueue_token.customer_id
  end
end
