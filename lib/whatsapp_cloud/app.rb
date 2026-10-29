module WhatsappCloud
  # Your Tech Provider app. Its app access token (`app_id|app_secret`) may call `debug_token`; nothing it does acts on
  # a business's accounts.
  class App
    MANAGEMENT_SCOPE = "whatsapp_business_management"
    SIGNATURE_PREFIX = "sha256="

    def initialize(app_id:, app_secret:, connection: Connection)
      raise Errors::ConfigurationError, "Missing Meta app id or secret" if [app_id, app_secret].any? { it.to_s.empty? }

      @app_id = app_id
      @app_secret = app_secret
      @connection = connection
    end

    # Embedded Signup's code lives for 30 seconds, so this runs as soon as it arrives.
    def exchange_code(code)
      data = graph.get("oauth/access_token", client_id: @app_id, client_secret: @app_secret, code:)
      data.fetch("access_token") { raise Errors::Error, "Meta answered the code exchange without a token" }
    end

    # The WhatsApp Business Accounts the business granted this token, newest first. They come from Meta, never
    # from the signup page, which the browser could alter.
    def granted_account_ids(token)
      scopes = graph.get("debug_token", input_token: token).dig("data", "granular_scopes") || []
      scopes.find { it["scope"] == MANAGEMENT_SCOPE }&.fetch("target_ids", nil) || []
    end

    # Meta signs each webhook's raw body with the app secret and sends `X-Hub-Signature-256: sha256=<hex>`.
    def signature_valid?(body:, signature:)
      return false if signature.to_s.empty?

      expected = OpenSSL::HMAC.hexdigest("SHA256", @app_secret, body.to_s)
      OpenSSL.secure_compare(expected, signature.to_s.delete_prefix(SIGNATURE_PREFIX))
    end

    def inspect
      "#<#{self.class.name} app_id=#{@app_id.inspect} app_secret=[FILTERED]>"
    end
    alias_method :to_s, :inspect

    private

    def graph = Graph.new(access_token: "#{@app_id}|#{@app_secret}", connection: @connection)
  end
end
