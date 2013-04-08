#! /usr/bin/ruby

require 'state.rb'
require 'square.rb'
require 'move.rb'

if ARGV[0] == 'random'
  beginning = Time.now
  board = State.new()
  board.randomGame
  puts "Time elapsed #{Time.now - beginning} seconds"
else
  board = State.new()
  board.humanPlay
end
