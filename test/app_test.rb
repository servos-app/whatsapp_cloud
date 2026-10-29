require_relative "test_helper"

class WhatsappCloud::AppTest < Minitest::Test
  def setup
    @connection = FakeConnection.new
    @app = WhatsappCloud::App.new(app_id: "123", app_secret: "app-secret", connection: @connection)
  end

  def test_exchanges_the_signup_code_for_the_business_token
    @connection.respond_with(body: {access_token: "business-token", token_type: "bearer"})

    assert_equal "business-token", @app.exchange_code("signup-code")

    request = @connection.last_request
    assert_equal "/v26.0/oauth/access_token", request.uri.path
    assert_equal({"client_id" => "123", "client_secret" => "app-secret", "code" => "signup-code"},
      URI.decode_www_form(request.uri.query).to_h)
  end

  def test_reads_the_granted_accounts_from_meta
    @connection.respond_with(body: {data: {granular_scopes: [
      {scope: "business_management", target_ids: ["9"]},
      {scope: "whatsapp_business_management", target_ids: ["waba-2", "waba-1"]}
    ]}})

    assert_equal ["waba-2", "waba-1"], @app.granted_account_ids("business-token")

    request = @connection.last_request
    assert_equal "Bearer 123|app-secret", request["Authorization"]
    assert_equal({"input_token" => "business-token"}, URI.decode_www_form(request.uri.query).to_h)
  end

  def test_no_granted_accounts_without_the_management_scope
    @connection.respond_with(body: {data: {granular_scopes: [{scope: "business_management", target_ids: ["9"]}]}})

    assert_empty @app.granted_account_ids("business-token")
  end

  def test_verifies_the_webhook_signature
    body = '{"object":"whatsapp_business_account"}'
    signature = "sha256=#{OpenSSL::HMAC.hexdigest("SHA256", "app-secret", body)}"

    assert @app.signature_valid?(body:, signature:)
    refute @app.signature_valid?(body: "#{body} ", signature:)
    refute @app.signature_valid?(body:, signature: nil)
  end

  def test_keeps_the_secret_out_of_inspect
    refute_includes @app.inspect, "app-secret"
    assert_raises(WhatsappCloud::Errors::ConfigurationError) { WhatsappCloud::App.new(app_id: "123", app_secret: "") }
  end
end
