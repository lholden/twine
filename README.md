# Twine

A light-weight forking library.

While there are many other libraries available to work with forked processes, most of them 
seem to be either very specific or want to include way too much.

Twine on the other hand is intended to be light weight and easy to use. Inspired by Fibers and Threads, a Twine is for producing 'heavy weight' (forked / multi-process) parallelism.

## Questions and Answers

### Why use Twine instead of `Process.fork`?

`Process.fork` gets the job done but leaves a lot of the bootstrapping to you; Forking off as a daemon can be a bit of black magic for example. Twine provides a lot of this bootstrapping for you.

### How do I create a daemon process?
```ruby
 Twine.daemonize {:output_to => '/tmp/my.log'}
 puts "This is now a backgrounded 'daemon' process"
 trap("TERM") { exit }
 while true do
   sleep 1
 end
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
 Twine.clean_fork { puts "I'm another process" }
```

### Is there an IPC / Message Queue mechanism?

Nope! Why re-invent the wheel when [ZeroMQ][zeromq] does a fantastic job of this already.

```ruby
 ctx = ZMQ::Context.new(1)

 outbound = ctx.socket(ZMQ::PUSH)
 outbound.bind("ipc:///tmp/my.ipc")

 inbound = ctx.socket(ZMQ::PULL)
 inbound.connect("ipc:///tmp/my.ipc")

 outbound.send_string("world")

 puts("Hello %s" %[inbound.socket.recv_string])

 outbound.close
 inbound.close
```

### Is there an easy way to accept command line arguments for my daemon?

Not built in. Check out awesome [Optitron][optitron] for a great solution to this.

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
