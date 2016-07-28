module Tracker
  HEARTBEAT_URL = 'http://trck.localtunnel.me/heartbeats'


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
