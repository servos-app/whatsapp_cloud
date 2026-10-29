module WhatsappCloud
  class Response
    attr_reader :status, :body, :headers

    def initialize(status:, body:, headers: {})
      @status = status
      @body = body
      @headers = headers
    end

    def success? = status.between?(200, 299)

    def data
      @data ||= (body.nil? || body.empty?) ? {} : JSON.parse(body)
    rescue JSON::ParserError
      @data = {}
    end
  end
end
