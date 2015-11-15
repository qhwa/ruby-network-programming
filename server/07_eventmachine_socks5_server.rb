require 'eventmachine'
require 'logger'
require 'stringio'

class Server

  def start(bind: '0.0.0.0', port: nil)
    EM.run do
      EM.start_server bind, port, Socks5Handler
    end
  end

  # SOCKS5 proxy server
  # RFC#1928: https://www.ietf.org/rfc/rfc1928.txt
  module Socks5Handler

    SOCKS_GREETING       = "\x05\x02\x00\x01"
    SOCKS_GREETING_REPLY = "\x05\x00"
    SOCKS_CONNECT        = "\x05\x01\x00\x03"
    SOCKS_CONNECT_REPLY  = "\x05\x00\x00\x01\x00\x00\x00\x00\x00\x00"

    attr_accessor :dest_host, :dest_port

    def post_init
      @client_addr = client_addr
      log { "new client connected from: %s:%d" % client_addr }
    end

    # Everytime client send data to server, this method will be invoked
    def receive_data data
      unless @proxy_conn
        if data == SOCKS_GREETING
          send_data SOCKS_GREETING_REPLY
          return
        end

        io = StringIO.new(data)
        if io.read(4) == SOCKS_CONNECT
          len = io.getbyte
          self.dest_host = io.read(len)
          self.dest_port = io.read(2).unpack("n").first
          log { "destination: %s:%d" % [dest_host, dest_port] }

          start_proxy
          send_data SOCKS_CONNECT_REPLY
        end
        return
      end

      @proxy_conn.send_data data
    end

    def start_proxy

      proxy_handler = Module.new do

        def initialize client
          @client = client
        end

        def post_init
          EM.enable_proxy self, @client
        end

        def proxy_target_unbound
          close_connection
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
