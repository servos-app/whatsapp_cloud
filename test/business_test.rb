require_relative "test_helper"

class WhatsappCloud::BusinessTest < Minitest::Test
  def setup
    @connection = FakeConnection.new
    @business = WhatsappCloud::Business.new(access_token: "business-token", connection: @connection)
  end

  def test_lists_an_accounts_phone_numbers
    @connection.respond_with(body: {data: [{id: "pn-1", display_phone_number: "+47 412 34 567"}]})

    assert_equal [{"id" => "pn-1", "display_phone_number" => "+47 412 34 567"}], @business.phone_numbers("waba-1")
    assert_equal "/v26.0/waba-1/phone_numbers", @connection.last_request.uri.path
    assert_equal "Bearer business-token", @connection.last_request["Authorization"]
  end

  def test_subscribes_and_unsubscribes_the_app
    @business.subscribe_app("waba-1")
    @business.unsubscribe_app("waba-1")

    assert_equal [["POST", "/v26.0/waba-1/subscribed_apps"], ["DELETE", "/v26.0/waba-1/subscribed_apps"]],
      @connection.requests.map { [it.method, it.uri.path] }
  end

  def test_registers_a_number_with_its_pin
    @business.register("pn-1", pin: "123456")

    request = @connection.last_request
    assert_equal "/v26.0/pn-1/register", request.uri.path
    assert_equal({"messaging_product" => "whatsapp", "pin" => "123456"}, JSON.parse(request.body))
  end

  def test_graph_errors_carry_the_code_not_metas_message
    @connection.respond_with(status: 400, body: {error: {message: "Fjordhotel's token expired", code: 190,
      error_subcode: 463, fbtrace_id: "trace"}})

    error = assert_raises(WhatsappCloud::Errors::AuthenticationError) { @business.phone_numbers("waba-1") }

    assert_equal "HTTP 400, code 190, subcode 463", error.message
    assert_equal ["Fjordhotel's token expired", "trace"], [error.graph_message, error.trace_id]
  end

  def test_errors_by_graph_code
    {200 => WhatsappCloud::Errors::PermissionError, 80007 => WhatsappCloud::Errors::RateLimitError,
     1 => WhatsappCloud::Errors::Error}.each do |code, error_class|
      @connection.respond_with(status: 400, body: {error: {code:}})

      error = assert_raises(error_class) { @business.subscribe_app("waba-1") }
      assert_equal code, error.code
    end

    @connection.respond_with(status: 503, body: "")
    assert_raises(WhatsappCloud::Errors::ServerError) { @business.subscribe_app("waba-1") }
  end
end
