require "json"
require "net/http"
require "openssl"
require "uri"

require_relative "whatsapp_cloud/version"
require_relative "whatsapp_cloud/errors"
require_relative "whatsapp_cloud/response"
require_relative "whatsapp_cloud/connection"
require_relative "whatsapp_cloud/graph"
require_relative "whatsapp_cloud/app"
require_relative "whatsapp_cloud/business"
require_relative "whatsapp_cloud/webhook"

# Meta WhatsApp Cloud API client for a Tech Provider.
#
# `App` is SERVOS's own Meta app: it turns an Embedded Signup code into the business's token and reads which
# WhatsApp Business Accounts that token was granted. `Business` acts with that token on the business's accounts
# and numbers.
#
# @example
#   app = WhatsappCloud::App.new(app_id: ENV["META_APP_ID"], app_secret: ENV["META_APP_SECRET"])
#   token = app.exchange_code(params[:code])
#   app.granted_account_ids(token).each do |account_id|
#     business = WhatsappCloud::Business.new(access_token: token)
#     business.subscribe_app(account_id)
#     business.phone_numbers(account_id).each { business.register(it["id"], pin: "123456") }
#   end
#
#   app.signature_valid?(body: request.raw_post, signature: request.headers["X-Hub-Signature-256"])
#
# @see https://developers.facebook.com/documentation/business-messaging/whatsapp/embedded-signup/onboarding-customers-as-a-tech-provider
module WhatsappCloud
end
