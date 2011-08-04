#!/bin/env ruby

#
# This stuff will look a lot better with Twine::Pool implemented. 
# Also looking into a crash issue that happens when the children are 
# started after the master's 0mq socket is setup.
#

require "rubygems"
require "bundler/setup"

require 'twine'
require 'ffi-rzmq'
require 'optitron'

ROOT_PATH = File.expand_path(File.dirname(__FILE__))
TMP_PATH = File.join(ROOT_PATH, 'tmp')
PID_FILE = File.join(TMP_PATH, 'master.pid')
LOG_FILE = File.join(TMP_PATH, 'master.log')
IPC_FILE = File.join(TMP_PATH, 'master.ipc')

class Slave
  include Twine::ChildMixin

  def run
    puts "#{Process.pid}: Started"
    ctx = ZMQ::Context.new(1)
    @socket = ctx.socket(ZMQ::PULL)
    @socket.connect("ipc://#{IPC_FILE}")
    @socket.setsockopt(ZMQ::LINGER, 0)

    main_loop
  end

protected
  def main_loop
    @running = true
    trap('TERM') { @running = false }
    begin
      while @running do
        while msg = @socket.recv_string(ZMQ::NOBLOCK) do
          puts "#{Process.pid}: I just consumed: #{msg}"
        end
        sleep 2
      end
    ensure
      puts "#{Process.pid}: Shutting Down"
      @socket.close
    end

  rescue ZMQ::SocketError => e
    puts "Socket terminated: #{e.message}"
  end
end

class Master
  include Optitron::ClassDsl

  desc "Start up the daemon"
  def start
    puts "Starting Master"
    Twine.daemonize(:pid_file => PID_FILE, :output_to => LOG_FILE)
    puts "\n\n\nMaster: Started"

    @slaves = [Slave.new, Slave.new, Slave.new]
    @slaves.each {|s| s.start}

    ctx = ZMQ::Context.new(1)
    @socket = ctx.socket(ZMQ::PUSH)
    @socket.bind("ipc://#{IPC_FILE}")
    @socket.setsockopt(ZMQ::LINGER, 0)

    main_loop
  rescue Twine::PidFileException => e
    die(e.message)
  end

  desc "Stop the daemon"
  def stop
    Process.kill('TERM', File.read(PID_FILE).strip.to_i)
    puts "Stop requested"
  rescue Errno::ENOENT => e
    die e.message
  rescue Errno::ESRCH => e
    die "Unable to stop: #{e.message} (pid: #{pid})"
  end

  desc "Get the daemons status"
  def status
    Process.kill(0, File.read(PID_FILE).strip.to_i)
    puts "Running"
  rescue Errno::ESRCH, Errno::ENOENT
    puts "Stopped"
  end

protected
  def main_loop
    @active = true
    trap('TERM') { @active = false }
    begin
      while @active do
        msg = rand(36**10).to_s(36)
        @socket.send_string(msg)
        puts "Master: #{msg}"
        sleep 1
      end
    ensure
      puts "Master: Shutting down"
      @socket.close 
      @slaves.each {|s| s.stop; s.join}
    end
  end

  def die(msg)
    STDERR << msg << "\n"
    exit 1
  end
end

if __FILE__ == $0
  Master.dispatch
end
