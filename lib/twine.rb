module Twine
  autoload :Child, 'twine/child'
  autoload :ChildMixin, 'twine/child_mixin'

  DaemonizeException     = Class.new Exception
  ProcessLeaderException = Class.new DaemonizeException
  PidFileException       = Class.new DaemonizeException

  DEV_NULL = "/dev/null"

  # Allow the current process to become backgrounded
  # :pid_file  => path, or nil
  # :output_to => path, io, or nil
  # returns process group id
  def self.daemonize(options = {})
    options = { 
      :chdir_path => '/',
      :output_to  => :null
    }.merge(options)

    pid_file   = options.delete :pid_file
    output_to  = options.delete :output_to
    chdir_path = options.delete :chdir_path

    # Let go of the terminal and become a process leader
    exit if clean_fork
    unless sid = Process.setsid
      raise(ProcessLeaderException, "unable to become a process leader")
    end

    Dir.chdir(chdir_path)    unless chdir_path.nil?
    setup_pid_file(pid_file) unless pid_file.nil?
    redirect_std_io(output_to)

    sid
  end
  
  def self.clean_fork
    (pid = Process.fork) and return pid

    srand   
    close_nonstd_io
    normalize_traps

    if block_given?
      yield 
      exit
    end

    nil
  end

protected
  def self.setup_pid_file(path)
    raise(PidFileException, "Pid file #{path} already present!") if File.file?(path)
    pid = Process.pid

    File.open(path, 'w') {|f| f << pid}

    # Ensure that the pid file gets destroyed
    at_exit do
      File.delete(path) if (pid == Process.pid) && File.file?(path)
    end
  end

  def self.redirect_std_io(output_to)
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

  def self.close_nonstd_io
    ObjectSpace.each_object(IO) do |io|
      next if [STDIN, STDOUT, STDERR].include?(io)
 
      begin
        io.close unless io.closed?
      rescue IOError
      end
    end
  end

  def self.normalize_traps
    (Signal.list.keys - ['VTALRM']).each {|s| trap(s, 'DEFAULT')}
  end

end
