module Tracker
  HEARTBEAT_URL = 'http://tracker.edgarfisher.com/heartbeats'


  HTTP_ERRORS = [
    EOFError,
    Errno::ECONNRESET,
    Errno::EINVAL,
    Errno::ECONNREFUSED,
    Net::HTTPBadResponse,
    Net::HTTPHeaderSyntaxError,
    Net::ProtocolError,
    Timeout::Error,
    SocketError,

  ]
end
