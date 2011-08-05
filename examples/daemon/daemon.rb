#!/usr/bin/env ruby

#
# This stuff will look a little better with Twine::Pool implemented. 
#
# start the daemon with:
#   ruby daemon.rb start
#
# for help:
#   ruby daemon.rb 
#

require "rubygems"
require "bundler/setup"

require 'twine'
require 'ffi-rzmq'
require 'optitron'
require 'logger'

ROOT_PATH = File.expand_path(File.dirname(__FILE__))
TMP_PATH = File.join(ROOT_PATH, 'tmp')
PID_FILE = File.join(TMP_PATH, 'master.pid')
LOG_FILE = File.join(TMP_PATH, 'daemon.log')
IPC_FILE = File.join(TMP_PATH, 'dispatcher.ipc')

require File.join(ROOT_PATH, 'dispatcher')
require File.join(ROOT_PATH, 'consumer')

class Master
  include Optitron::ClassDsl

  desc "Start up the daemon"
  def start
    pid = Twine.daemonize(:pid_file => PID_FILE, :output_to => LOG_FILE) do
      puts "\n\n\n"
      log = Logger.new(STDOUT)
      log.info "Master started"

      slaves = [Dispatcher.new]
      3.times {slaves << Consumer.new}

      slaves.each {|s| s.start}
      trap('TERM') { slaves.each {|s| s.stop} }
      slaves.each {|s| s.join}

      log.info "Master shutting down"
    end
    puts "Daemon started (pid: #{pid})"
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
  def die(msg)
    STDERR << msg << "\n"
    exit 1
  end
end

if __FILE__ == $0
  Master.dispatch
end
