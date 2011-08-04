class Consumer
  include Twine::ChildMixin

  def run
    log = Logger.new(STDOUT)
    log.info "Consumer started"
    
    ctx = ZMQ::Context.new(1)
    socket = ctx.socket(ZMQ::PULL)
    socket.connect("ipc://#{IPC_FILE}")
    socket.setsockopt(ZMQ::LINGER, 0)

    running = true
    trap('TERM') { running = false }

    begin
      while running
        while msg = socket.recv_string(ZMQ::NOBLOCK) do
          log.info "I just consumed: #{msg}"
        end
        sleep 1
      end
    ensure
      log.info "Consumer shutting Down"
      socket.close
      ctx.terminate
    end

  rescue ZMQ::SocketError => e
    log.error "Socket terminated: #{e.message}"
  end
end

