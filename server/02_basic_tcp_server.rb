require 'socket'
require 'logger'

class Server

  def start(bind: '0.0.0.0', port: nil)
    Socket.tcp_server_loop(bind, port) do |sock, client_addr|
      log { "client connected: %s:%d" % [client_addr.ip_address, client_addr.ip_port] }
      sock.puts Time.now
      sock.close
    end
  end

  def log(msg=nil, &block)
    Logger.new(STDOUT).debug msg, &block
  end

end

Server.new.start(port: 23333, bind: '127.0.0.1')
