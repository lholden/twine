# Twine

A light-weight forking library.

While there are many other libraries available to handle forking, most of them 
seem to be either very specific, or want to include way too much. 

Twine on the other hand is intended to be light weight and easy to use. 
Inspired by Fibers and Threads, a Twine for producing 'heavy weight' (forked 
/ multi-process) parallelism.

Twine is still in very early stages, you have been warned.

## Questions and Answers

### Is there an easy way to accept command line arguments for my daemon?

Not built in. Check out [Optitron][optitron] for a great solution to this.

### Is there an IPC mechanism?

Nope! Why re-invent the wheel, [ZeroMQ][zeromq] does a fantastic job of this already.

### You mention [Optitron][optitron] and [ZeroMQ][zeromq], how do I use them with Twine?

Check out the example at https://github.com/lholden/twine/tree/master/examples/daemon

## Examples

See the `examples` directory more detailed examples, including uses of backgrounding, children, and IPC (ZeroMQ).

### Background a process
```ruby
 Twine.daemonize {:output_to => '/tmp/my.log'}
 puts "This is now a backgrounded 'daemon' process"
 trap("TERM") { exit }
 while true do
   sleep 1
 end
```

### Child process
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

## Unimplemented
 * Pooling

## Copyright
Copyright (c) 2011 Lori Holden. See LICENSE.txt for further details.


[optitron]: https://github.com/joshbuddy/optitron  "Sensible, minimal simple options parsing and dispatching for Ruby. Build a CLI with no fuss."
[ZeroMQ]: http://www.zeromq.org/  "The Intelligent Transport Layer"
