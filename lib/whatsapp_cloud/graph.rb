module WhatsappCloud
  # One Graph API request, authorized with a bearer token.
  class Graph
    BASE_URL = "https://graph.facebook.com"

    def initialize(access_token:, connection: Connection, base_url: BASE_URL)
      raise Errors::ConfigurationError, "Missing access token" if access_token.to_s.strip.empty?

      @access_token = access_token
      @connection = connection
      @base_url = base_url
    end

    def get(path, query = {}) = perform(Net::HTTP::Get.new(uri(path, query)))

    def post(path, body = nil)
      request = Net::HTTP::Post.new(uri(path))
      if body
        request["Content-Type"] = "application/json"
        request.body = JSON.generate(body)
      end
      perform(request)
    end

    def delete(path) = perform(Net::HTTP::Delete.new(uri(path)))

    def inspect
      "#<#{self.class.name} access_token=[FILTERED]>"
    end
    alias_method :to_s, :inspect

    private

    def uri(path, query = {})
      uri = URI("#{@base_url}/#{GRAPH_VERSION}/#{path}")
      uri.query = URI.encode_www_form(query) if query.any?
      uri
    end

    def perform(request)
      request["Authorization"] = "Bearer #{@access_token}"
      request["Accept"] = "application/json"

      response = @connection.perform(request)
      raise Errors.from(response) unless response.success?

      response.data
    end
  end
end
