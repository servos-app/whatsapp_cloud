module WhatsappCloud
  module Errors
    # Graph's own message can quote the business's data, so an error's message is its code only; the
    # message stays readable on `graph_message` for whoever handles it.
    class Error < StandardError
      attr_reader :response, :code, :subcode

      def initialize(message = nil, response: nil, code: nil, subcode: nil)
        @response = response
        @code = code
        @subcode = subcode
        super(message)
      end

      def graph_message = graph_error["message"]

      def trace_id = graph_error["fbtrace_id"]

      private

      def graph_error
        error = response&.data&.dig("error") if response&.data.is_a?(Hash)
        error.is_a?(Hash) ? error : {}
      end
    end

    # 190: the token expired or was revoked, for instance when the business removed the app.
    class AuthenticationError < Error; end

    # 10 and 200–299: the token lacks a permission, or the app lacks advanced access to it.
    class PermissionError < Error; end

    # 4, 80007, 130429 and 131056: Graph's rate and throughput limits.
    class RateLimitError < Error; end

    class ServerError < Error; end

    class ConnectionError < Error; end

    class TimeoutError < Error; end

    class ConfigurationError < Error; end

    RATE_LIMIT_CODES = [4, 80007, 130429, 131056].freeze

    def self.from(response)
      error = response.data.is_a?(Hash) ? response.data["error"] : nil
      code = error["code"] if error.is_a?(Hash)
      subcode = error["error_subcode"] if error.is_a?(Hash)
      error_class(response.status, code).new(message(response.status, code, subcode), response:, code:, subcode:)
    end

    def self.error_class(status, code)
      if code == 190 then AuthenticationError
      elsif code == 10 || (200..299).cover?(code) then PermissionError
      elsif RATE_LIMIT_CODES.include?(code) then RateLimitError
      elsif status >= 500 then ServerError
      else Error
      end
    end

    def self.message(status, code, subcode)
      ["HTTP #{status}", code && "code #{code}", subcode && "subcode #{subcode}"].compact.join(", ")
    end

    private_class_method :error_class, :message
  end
end
