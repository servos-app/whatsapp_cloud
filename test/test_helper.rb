require "minitest/autorun"
require_relative "../lib/whatsapp_cloud"

class FakeConnection
  attr_reader :requests

  def initialize
    @requests = []
    @responses = []
  end

  def respond_with(status: 200, body: {})
    @responses << WhatsappCloud::Response.new(status: status, body: body.is_a?(String) ? body : body.to_json)
    self
  end

  def perform(request)
    @requests << request
    @responses.shift || WhatsappCloud::Response.new(status: 200, body: "{}")
  end

  def last_request = requests.last
end
