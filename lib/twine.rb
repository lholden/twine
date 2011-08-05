# A light-weight forking library.
# https://github.com/lholden/twine
#
# Author::    Lori Holden  (mailto:email@loriholden.com)
# Copyright:: Copyright (c) 2011 Lori Holden.
# License::   See LICENSE.txt for details.

module Twine
  autoload :Child, 'twine/child'
  autoload :ChildMixin, 'twine/child_mixin'

  DaemonizeException     = Class.new Exception
  ProcessLeaderException = Class.new DaemonizeException
  PidFileException       = Class.new DaemonizeException

  DEV_NULL = "/dev/null"

  # Allow the current process to become backgrounded
  #
  # Expects a block to be passed in.
  # options:
  #   :pid_file  => path, or nil
  #   :output_to => path, io, or nil
  #
  # returns the process group id
  def self.daemonize(options = {}, &bl)
    options = { 
      :chdir_path => '/',
      :output_to  => :null
    }.merge(options)

    pid_file   = options.delete :pid_file
    output_to  = options.delete :output_to
    chdir_path = options.delete :chdir_path

    # Fork and allow the new process to become the process leader
    clean_fork do |pid|
      unless sid = Process.setsid
        raise(ProcessLeaderException, "unable to become a process leader")
      end

      Dir.chdir(chdir_path)    unless chdir_path.nil?
      setup_pid_file(pid_file) unless pid_file.nil?
      redirect_std_io(output_to)

      bl.call(pid)
      exit
    end
  end

  class << self
    alias :long_running :daemonize
  end
  
  # Cleanly fork off a new process
  # 
  # Expects a block to be passed in.
  def self.clean_fork(&bl)
    (pid = Process.fork) and return pid

    srand   
    close_nonstd_io
    normalize_traps

    bl.call(Process.pid)
    exit
  end

protected

  # Create a pid file for the current process
  def self.setup_pid_file(path) #:nodoc:
    raise(PidFileException, "Pid file #{path} already present!") if File.file?(path)
    pid = Process.pid

    File.open(path, 'w') {|f| f << pid}

    # Ensure that the pid file gets destroyed
    at_exit do
      File.delete(path) if (pid == Process.pid) && File.file?(path)
    end
  end

  # Redirect STDERR and STDOUT to the specified file/io. 
  # Redirect STDIO to null.
  def self.redirect_std_io(output_to) #:nodoc:
    STDIN.reopen DEV_NULL

    return if output_to.nil?

    args = case output_to
           when :null   then [DEV_NULL]
           when String  then [output_to, 'a']
           else              [output_to]
           end

    STDOUT.reopen(*args)
    STDERR.reopen STDOUT
    STDOUT.sync = true
    STDERR.sync = true
  end

  # Make sure that no IO connections follow us over to the new forked process
  def self.close_nonstd_io #:nodoc:
    ObjectSpace.each_object(IO) do |io|
      next if [STDIN, STDOUT, STDERR].include?(io)
 
      begin
        io.close unless io.closed?
      rescue IOError
      end
    end
  end

  # Make sure that no traps follow us over to the new forked process
  def self.normalize_traps #:nodoc:
    (Signal.list.keys - ['VTALRM']).each {|s| trap(s, 'DEFAULT')}
  end

end
