require_relative "test_helper"

class WhatsappCloud::WebhookTest < Minitest::Test
  def test_echoes_the_challenge_for_the_right_verify_token
    params = {"hub.mode" => "subscribe", "hub.verify_token" => "verify-me", "hub.challenge" => "1158201444"}

    assert_equal "1158201444", WhatsappCloud::Webhook.challenge(params, verify_token: "verify-me")
    assert_nil WhatsappCloud::Webhook.challenge(params, verify_token: "other")
    assert_nil WhatsappCloud::Webhook.challenge(params.merge("hub.mode" => "unsubscribe"), verify_token: "verify-me")
    assert_nil WhatsappCloud::Webhook.challenge(params, verify_token: nil)
  end

  def test_splits_a_body_into_changes_per_account_and_number
    body = {object: "whatsapp_business_account", entry: [
      {id: "waba-1", changes: [{field: "messages", value: {metadata: {phone_number_id: "pn-1"}, messages: []}}]},
      {id: "waba-2", changes: [{field: "account_update", value: {event: "PARTNER_REMOVED"}}]}
    ]}.to_json

    changes = WhatsappCloud::Webhook.changes(body)

    assert_equal [["waba-1", "messages", "pn-1"], ["waba-2", "account_update", nil]],
      changes.map { [it.account_id, it.field, it.phone_number_id] }
    assert_equal changes, WhatsappCloud::Webhook.changes(JSON.parse(body))
    assert_equal [false, true], changes.map(&:partner_removed?)
  end
end
