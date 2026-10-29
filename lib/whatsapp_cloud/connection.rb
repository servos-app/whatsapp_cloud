module WhatsappCloud
  module Connection
    OPEN_TIMEOUT = 10
    READ_TIMEOUT = 30
    NETWORK_ERRORS = [
      Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::EHOSTUNREACH, SocketError, OpenSSL::SSL::SSLError, EOFError
    ].freeze

    def self.perform(request, timeout: READ_TIMEOUT, open_timeout: OPEN_TIMEOUT)
      uri = request.uri
      options = {use_ssl: uri.scheme == "https", open_timeout: open_timeout, read_timeout: timeout}

      http_response = Net::HTTP.start(uri.host, uri.port, **options) { |http| http.request(request) }
      Response.new(status: http_response.code.to_i, body: http_response.body, headers: http_response.to_hash)
    rescue *NETWORK_ERRORS => e
      raise Errors::ConnectionError.new("Connection failed: #{e.class}")
    rescue Net::OpenTimeout
      raise Errors::TimeoutError.new("Connection timed out")
    rescue Net::ReadTimeout, Net::WriteTimeout
      raise Errors::TimeoutError.new("Request timed out")
    end
  end
end
