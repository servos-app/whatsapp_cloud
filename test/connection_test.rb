require_relative "test_helper"
require "socket"

class WhatsappCloud::ConnectionTest < Minitest::Test
  def test_wraps_the_status_and_body
    server = TCPServer.new("127.0.0.1", 0)
    answer = Thread.new do
      socket = server.accept
      socket.gets("\r\n\r\n")
      socket.write "HTTP/1.1 200 OK\r\nContent-Length: 11\r\nConnection: close\r\n\r\n{\"ok\":true}"
      socket.close
    end
    request = Net::HTTP::Get.new(URI("http://127.0.0.1:#{server.addr[1]}/v26.0/me"))

    response = WhatsappCloud::Connection.perform(request, timeout: 5, open_timeout: 5)

    assert_equal [200, {"ok" => true}], [response.status, response.data]
  ensure
    answer&.kill
    server&.close
  end

  def test_a_refused_connection_becomes_a_connection_error
    request = Net::HTTP::Get.new(URI("http://127.0.0.1:1/v26.0/me"))

    assert_raises(WhatsappCloud::Errors::ConnectionError) { WhatsappCloud::Connection.perform(request, timeout: 1, open_timeout: 1) }
  end
end
