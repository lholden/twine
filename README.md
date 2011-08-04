# Twine

A light-weight forking library.

While there are many other libraries available to handle forking, most of them 
seem to be either very specific, or want to include way too much. 

Twine on the other hand is intended to be light weight and easy to use. 
Inspired by Fibers and Threads, a Twine for producing 'heavy weight' (forked 
/ multi-process) parallelism.

Twine is still in very early stages, you have been warned.

## Examples

### Background a process
```ruby
 Twine.daemonize {:output_to => '/tmp/my.log'}
 puts "This is now a backgrounded 'daemon' process"
 trap("TERM") { exit }
 while true do
   sleep 1
 end
```

NOTE: Examples of Child processes, pooling, and IPC to come.

## Copyright
Copyright (c) 2011 Lori Holden. See LICENSE.txt for further details.
