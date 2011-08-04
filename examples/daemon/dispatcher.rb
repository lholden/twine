class Dispatcher
  include Twine::ChildMixin

  def run
    puts "Dispatcher: Started"

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
          puts "Dispatcher: #{msg}"
        end
        sleep 4
      end
    ensure
      puts "Dispatcher: Shutting down"
      socket.close 
    end

  end
end
