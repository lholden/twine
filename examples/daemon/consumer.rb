class Consumer
  include Twine::ChildMixin

  def run
    log = Logger.new(STDOUT)
    log.info "Consumer started"
    
    ctx = ZMQ::Context.new
    socket = ctx.socket(ZMQ::PULL)
    socket.connect("ipc://#{IPC_FILE}")
    socket.setsockopt(ZMQ::LINGER, 0)

    running = true
    trap('TERM') { running = false }
    trap('INT') { running = false }    

    begin
      while running 
        # Non blocking because we can't otherwise catch signals due to how
        # ruby and zmq threading interact in ruby 1.8
        while msg = socket.recv_string(ZMQ::NOBLOCK)
          log.info "I just consumed: #{msg}"
        end
        sleep 1
      end
    rescue ZMQ::SocketError => e
      log.error "Socket terminated: #{e.message}"
    ensure
      log.info "Consumer shutting Down"
      socket.close
      ctx.terminate
    end

  end
end

