require "rubygems"
require "bundler/setup"
require 'twine'

children = []
3.times { children << Twine::Child.new { sleep rand(5); puts "Hi!!" } }
children.each {|c| c.start}
# Children automatically join back up - the main process stays active until they die
