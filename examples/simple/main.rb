require "rubygems"
require "bundler/setup"
require 'twine'

LOGFILE = File.join(File.expand_path(File.dirname(__FILE__)), 'long_running.log')

children = []
3.times { children << Twine::Child.new { sleep rand(5); puts "Hi!!" } }
children.each {|c| c.start}
# Children automatically join back up - the main process stays active until they die

pid = Twine.daemonize(:output_to => LOGFILE) do
  sleep rand(5)
  puts "I did something to a log because I'm a daemon!"
end
# Daemonizing releases a fork that can be managed on its own.

puts "my daemons pid is #{pid}"
