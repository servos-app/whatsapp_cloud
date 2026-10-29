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
# `App` is your Tech Provider app: it turns an Embedded Signup code into the business's token and reads which
# WhatsApp Business Accounts that token was granted. `Business` acts with that token on the business's accounts
# and numbers.
#
# @see https://developers.facebook.com/documentation/business-messaging/whatsapp/embedded-signup/onboarding-customers-as-a-tech-provider
module WhatsappCloud
end
