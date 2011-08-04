# Twine

A light-weight forking library.

While there are many other libraries available to handle forking, most of them 
seem to be either very specific, or want to include way too much. 

Twine on the other hand is intended to be light weight and easy to use. 
Inspired by Fibers and Threads, a Twine for producing 'heavy weight' (forked 
/ multi-process) parallelism.

Twine is still in very early stages, you have been warned.

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
