# Twine

A light-weight forking library.

While there are many other libraries available to work with forked processes, most of them 
seem to be either very specific or want to include way too much.

Twine on the other hand is intended to be light weight and easy to use. Inspired by Fibers and Threads, a Twine is for producing 'heavy weight' (forked / multi-process) parallelism.

## Questions and Answers

### Why use Twine instead of `Process.fork`?

`Process.fork` gets the job done but leaves a lot of the bootstrapping to you; Forking off as a daemon can be a bit of black magic for example. Twine provides a lot of this bootstrapping for you.

* daemons / long running processes
  * pid file creation
  * output redirection
* clean forking
  * close off IO left over from the originating process
  * initialize a new seed for randomization
  * clean process traps created from the originating process
* child process API similar to threads
  * prevents zombie processes (Grrr, aaarg, brain!)


### How do I create a daemon process?
```ruby
 pid = Twine.daemonize {:output_to => '/tmp/my.log'} do
   puts "This is now a backgrounded 'daemon' process"
   trap("TERM") { exit }
   while true do
     sleep 1
   end
 end

 puts "I just made a daemon with pid #{pid}"
```

### How do I create a child process?
As an object

```ruby
 # Create a new child
 c = Twine::Child.new do
   puts "Time to do MP work!"
   sleep 5
   puts "Phew, that was hard"
 end
 c.start
 
 # Is it running?
 c.running?  # >>> true

 # Send it a signal
 c.signal :usr1

 # blocking wait for it to exit
 c.join     
```

As a MixIn

```ruby
 class MyChild
   include Twine::ChildMixin
 protected
   def run
     trap("TERM") { exit }
     while true do
       puts "annoying yet? Then terminate me!!!"
       sleep 1
     end
   end
 end

 c = MyChild.new
 c.start
 sleep 5
 c.kill # oi... that was annoying.
```

### I just want simpler forking!

```ruby
 pid = Twine.clean_fork { puts "I'm another process" }
```

### Is there an IPC / Message Queue mechanism?

Nope! Why re-invent the wheel when [ZeroMQ][zeromq] does a fantastic job of this already.

```ruby
 require 'rubygems'
 require "bundler/setup"
 require 'twine'
 require 'ffi-rzmq'

 a = Twine::Child.new do
   ctx = ZMQ::Context.new  # Unlike threads, each fork needs its own context
   outbound = ctx.socket(ZMQ::PUSH)
   outbound.bind("ipc:///tmp/my.ipc")
   outbound.send_string("world")
   outbound.close
   ctx.terminate
 end

 b = Twine::Child.new do 
   ctx = ZMQ::Context.new
   inbound = ctx.socket(ZMQ::PULL)
   inbound.connect("ipc:///tmp/my.ipc")
   puts("Hello %s" %[inbound.recv_string])
   inbound.close
   ctx.terminate
 end

 a.start; b.start
 a.join; b.join
```

### Is there an easy way to accept command line arguments for my daemon?

Not built in. Check out the awesome [Optitron][optitron] for a great solution to this.

### You mention [Optitron][optitron] and [ZeroMQ][zeromq], how do I use them with Twine?

Check out the example at https://github.com/lholden/twine/tree/master/examples/daemon

### Are there any other examples?

Check out the [examples][examples] directory.

## To be implemented
 * Pooling

## Copyright
Copyright (c) 2011 Lori Holden. See LICENSE.txt for further details.


[optitron]: https://github.com/joshbuddy/optitron  "Sensible, minimal simple options parsing and dispatching for Ruby. Build a CLI with no fuss."
[zeromq]: http://www.zeromq.org/  "The Intelligent Transport Layer"
[examples]: https://github.com/lholden/twine/tree/master/examples  "Examples of using Twine"
