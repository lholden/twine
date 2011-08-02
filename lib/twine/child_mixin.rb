module Twine
  module ChildMixin
    def start
      unless methods.include? "run"
        raise ArgumentError, "a run method must be defined!"
      end

      # ensure that we don't make a zombie of our child
      at_exit { join if Process.pid == Process.getpgrp }

      @_twine_child_pid = Process.fork do
        normalize_traps
        run
      end
    end

    # Ask the child process to exit
    def stop
      signal :term
    end

    # Exit the child process immediately
    def stop!
      signal :kill
    end

    def running?
      pid && !Process.waitpid(pid, Process::WNOHANG | Process::WUNTRACED)
    rescue Errno::ECHILD
      false
    end

    # Blocking wait until the child process exits
    def join
      running? && Process.waitpid(pid)
    rescue Errno::ECHILD
      false
    end

    # Send a posix compatible signal supported on your system
    def signal(name)
      name = case name
             when Symbol
               name.to_s.upcase
             when String
               name.upcase
             else
              raise ArgumentError, "Invalid argument type for a signal"
             end
      Process.kill name, pid
    end

    def pid
      @_twine_child_pid
    end
  protected
    def normalize_traps
      (Signal.list.keys - ['VTALRM']).each {|s| trap(s, 'DEFAULT')}
    end
  end
end
