module WhatsappCloud
  # Acts on one business's WhatsApp Business Accounts and numbers with the token its Embedded Signup gave us.
  class Business
    PHONE_NUMBER_FIELDS = %w[id display_phone_number verified_name name_status quality_rating messaging_limit_tier
      code_verification_status platform_type].freeze

    def initialize(access_token:, connection: Connection)
      @graph = Graph.new(access_token:, connection:)
    end

    def account(account_id) = @graph.get(account_id, fields: "id,name,currency,timezone_id")

    def phone_numbers(account_id)
      @graph.get("#{account_id}/phone_numbers", fields: PHONE_NUMBER_FIELDS.join(",")).fetch("data", [])
    end

    def phone_number(phone_number_id) = @graph.get(phone_number_id, fields: PHONE_NUMBER_FIELDS.join(","))

    # Sends the account's message, status and account webhooks to this app.
    def subscribe_app(account_id) = @graph.post("#{account_id}/subscribed_apps")

    def unsubscribe_app(account_id) = @graph.delete("#{account_id}/subscribed_apps")

    # Puts the number on the Cloud API, which a number already there (`platform_type` CLOUD_API) doesn't need.
    # `pin` becomes its two-step verification PIN, which a later registration of the same number needs again.
    def register(phone_number_id, pin:)
      @graph.post("#{phone_number_id}/register", {messaging_product: "whatsapp", pin:})
    end

    def deregister(phone_number_id) = @graph.post("#{phone_number_id}/deregister")

    def inspect = "#<#{self.class.name}>"
    alias_method :to_s, :inspect
  end
end
