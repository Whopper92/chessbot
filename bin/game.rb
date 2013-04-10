#! /usr/bin/ruby

require File.expand_path('../../lib/state.rb', __FILE__)

if ARGV[0] == 'random'
  beginning = Time.now
  board = State.new()
  board.randomGame
  puts "Time elapsed #{Time.now - beginning} seconds"
else
  board = State.new()
  board.humanPlay
end