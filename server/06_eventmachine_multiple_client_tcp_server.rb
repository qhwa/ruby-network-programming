require 'eventmachine'
require 'logger'

class Server

  def start(bind: '0.0.0.0', port: nil, backlog: 10)
    EM.run do
      EM.start_server bind, port, Handler
    end
  end

  def log(msg=nil, &block)
    Logger.new(STDOUT).debug msg, &block
  end

  module Handler
    def post_init
      log { "new client connected" }
    end
  end

end

Server.new.start(port: 23333, bind: '127.0.0.1')
