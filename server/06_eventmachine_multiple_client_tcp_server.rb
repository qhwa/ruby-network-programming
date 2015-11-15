require 'eventmachine'
require 'logger'

class Server

  def start(bind: '0.0.0.0', port: nil)
    EM.run { EM.start_server bind, port, Handler }
  end

  module Handler

    # Everytime a new client is connected, EventMachine will initialize
    # a new Connection class (or a class inheriting from Connection defined
    # by you). The instance of Connection class with automaticly invoke
    # `post_init` method
    def post_init
      log { "new client connected from: %s:%d" % client_addr }
    end

    # Everytime client send data to server, this method will be invoked
    def receive_data data
      data.chomp!
      if data == "q"
        close_connection
      else
        send_data data.reverse 
        send_data "\n"
      end
    end

    def unbind
      log { "client disconnected from: %s:%d" % client_addr }
    end

    private

      def log(msg=nil, &block)
        Logger.new(STDOUT).debug msg, &block
      end

      def client_addr
        @client_addr ||= Socket.unpack_sockaddr_in(get_peername).reverse
      end

  end

end

Server.new.start(port: 23333, bind: '127.0.0.1')
