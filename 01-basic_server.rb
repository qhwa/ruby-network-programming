require 'socket'
require 'logger'

# This program demos how to use ruby to create a basic
# C-style (bind-listen-read-write-close) TCP Server
class Server

  def start(bind: '0.0.0.0', port: nil, backlog: 10)
    
    sock = Socket.new(:INET, :STREAM)

    # bind
    sock.bind Addrinfo.tcp bind, port

    # listen
    sock.listen backlog
    log { "start server %s:%d" % [sock.local_address.ip_address, sock.local_address.ip_port] }

    client, client_addr = sock.accept
    log { "client connected from %s:%d" % [client_addr.ip_address, client_addr.ip_port] }

    client.puts "Hello there! %s" % Time.now
    loop do
      input = client.gets.chomp
      if input == "q"
        log { "client disconnected from %s:%d" % [client_addr.ip_address, client_addr.ip_port] }
        break
      else
        client.puts input.reverse
      end
    end
    client.close
  ensure
    sock.close
    sock = nil
  end

  def log(msg=nil, &block)
    Logger.new(STDOUT).debug msg, &block
  end

end

Server.new.start(port: 23333, bind: '127.0.0.1')
