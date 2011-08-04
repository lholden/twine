class Consumer
  include Twine::ChildMixin

  def run
    puts "#{Process.pid}: Started"
    
    ctx = ZMQ::Context.new(1)
    socket = ctx.socket(ZMQ::PULL)
    socket.connect("ipc://#{IPC_FILE}")
    socket.setsockopt(ZMQ::LINGER, 0)

    running = true
    trap('TERM') { running = false }

    begin
      while running
        while msg = socket.recv_string(ZMQ::NOBLOCK) do
          puts "#{Process.pid}: I just consumed: #{msg}"
        end
        sleep 1
      end
    ensure
      puts "#{Process.pid}: Shutting Down"
      socket.close
    end

  rescue ZMQ::SocketError => e
    puts "Socket terminated: #{e.message}"
  end
end

