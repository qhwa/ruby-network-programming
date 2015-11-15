require 'eventmachine'
require 'logger'
require 'stringio'

class Server

  def start(bind: '0.0.0.0', port: nil)
    EM.run { EM.start_server bind, port, Socks5Handler }
  end

  # SOCKS5 proxy server
  # RFC#1928: https://www.ietf.org/rfc/rfc1928.txt
  module Socks5Handler

    # we only support a few socks5 features for demo only
    SOCKS_GREETING       = "\x05\x02\x00\x01"
    SOCKS_GREETING_REPLY = "\x05\x00"
    SOCKS_CONNECT        = "\x05\x01\x00"
    SOCKS_CONNECT_REPLY  = "\x05\x00\x00\x01\x00\x00\x00\x00\x00\x00"

    attr_accessor :dest_host, :dest_port, :proxy_conn, :data

    def post_init
      @client_addr = client_addr
      log { "new client connected from: %s:%d" % client_addr }
    end

    def receive_data data
      @data = data
      if proxy_ready?
        proxy_conn.send_data data
      else
        greeting or connect
      end
    end

    def proxy_ready?
      !!proxy_conn
    end

    def greeting
      send_data SOCKS_GREETING_REPLY if data == SOCKS_GREETING
    end

    def connect
      io = StringIO.new(data)
      if io.read(3) == SOCKS_CONNECT
        self.dest_host =  case atype = io.getbyte
                          when 1
                            io.read(4).unpack("C*").join "."
                          when 3
                            io.read(io.getbyte)
                          when 4
                            io.read(16).unpack("n*").map {|i| i.to_s(16)}.join ":"
                          end
        self.dest_port = io.read(2).unpack("n").first
        start_proxy

        log { "destination connected: %s:%d" % [dest_host, dest_port] }
        send_data SOCKS_CONNECT_REPLY
      end
    end

    def start_proxy

      proxy_handler = Module.new do

        def initialize client
          @client = client
        end

        def receive_data data
          @client.send_data data
        end

        def unbind
          @client.close_connection_after_writing
        end
      end

      @proxy_conn ||= EM.connect(dest_host, dest_port, proxy_handler, self)
    end

    def unbind
      log { "client disconnected from: %s:%d" % @client_addr }
    end

    private

      def log(msg=nil, &block)
        Logger.new(STDOUT).debug msg, &block
      end

      def client_addr
        Socket.unpack_sockaddr_in(get_peername).reverse
      end

  end

end

Server.new.start(port: 23333, bind: '127.0.0.1')
