#! /usr/bin/ruby

require File.expand_path('../../lib/state.rb', __FILE__)
require File.expand_path('../../bin/client.rb', __FILE__)

  client = Client.new
  if ARGV[0] == 'loop'
    client.looper
  else
    client.playGame
  end

#  board = State.new()
#  board.tourneyGetMove("! a2-a3")
#  newMove = board.tourneySendMove
#  puts newMove
