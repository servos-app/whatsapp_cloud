module WhatsappCloud
  # Meta checks a webhook URL with a GET carrying `hub.mode=subscribe`, the verify token set in the app dashboard
  # and a challenge to echo back.
  module Webhook
    def self.challenge(params, verify_token:)
      return if verify_token.to_s.empty?
      return unless params["hub.mode"] == "subscribe"
      return unless OpenSSL.secure_compare(params["hub.verify_token"].to_s, verify_token.to_s)

      params["hub.challenge"]
    end

    # A webhook body groups changes by WhatsApp Business Account: `entry[].id` is the account, and each change's
    # `value.metadata.phone_number_id` the number it concerns, when it concerns one.
    def self.changes(body)
      JSON.parse(body).fetch("entry", []).flat_map do |entry|
        entry.fetch("changes", []).map { Change.new(account_id: entry["id"], field: it["field"], value: it["value"] || {}) }
      end
    end

    Change = Data.define(:account_id, :field, :value) do
      def phone_number_id = value.dig("metadata", "phone_number_id")
    end
  end
end
