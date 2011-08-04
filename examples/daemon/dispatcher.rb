class Dispatcher
  include Twine::ChildMixin

  def run
    log = Logger.new(STDOUT)
    log.info "Dispatcher Started"

    ctx = ZMQ::Context.new(1)
    socket = ctx.socket(ZMQ::PUSH)
    socket.bind("ipc://#{IPC_FILE}")
    socket.setsockopt(ZMQ::LINGER, 0)

    active = true
    trap('TERM') { active = false }

    begin
      while active do
        3.times do
          msg = rand(36**10).to_s(36)
          socket.send_string(msg)
          log.info "Dispatching: #{msg}"
        end
        sleep 4
      end
    ensure
      log.info "Dispatcher shutting down"
      socket.close 
      ctx.terminate
    end

  end
end
