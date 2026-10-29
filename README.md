# WhatsApp Cloud

A client for Meta's WhatsApp Cloud API, written for a Tech Provider: onboard a business through Embedded Signup, act on its accounts and numbers, and verify Meta's webhooks. Plain Ruby, no runtime dependencies.

## Installation

```ruby
gem "whatsapp_cloud", github: "servos-app/whatsapp_cloud"
```

## Usage

```ruby
app = WhatsappCloud::App.new(app_id: ENV["META_APP_ID"], app_secret: ENV["META_APP_SECRET"])
token = app.exchange_code(params[:code]) # within 30 seconds of the signup finishing

app.granted_account_ids(token).each do |account_id|
  business = WhatsappCloud::Business.new(access_token: token)
  business.subscribe_app(account_id)
  business.phone_numbers(account_id).each do |number|
    business.register(number["id"], pin: "123456") if number["platform_type"] == "NOT_APPLICABLE"
  end
end

app.signature_valid?(body: request.raw_post, signature: request.headers["X-Hub-Signature-256"])
WhatsappCloud::Webhook.challenge(request.query_parameters, verify_token: ENV["META_WEBHOOK_VERIFY_TOKEN"])
WhatsappCloud::Webhook.changes(request.raw_post).each { |change| change.phone_number_id }
```

Errors name Graph's error code, never its message, which can quote the business's data; `error.graph_message` has it.
