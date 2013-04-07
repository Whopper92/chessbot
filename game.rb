#! /usr/bin/ruby

require 'state.rb'
require 'square.rb'
require 'move.rb'

  board = State.new()
  board.printBoard
  board.getState
  puts "\n"
  board.printBoard
  puts "\n"
#  board.moveList(4,0)
#  board.moveList(3,0)
#  board.moveList(0,5)
#  board.moveList(1,5)
#  board.moveList(0,1)
#  board.moveList(2,0)
#  board.moveList(4,4)
#  board.moveList(2,5)
#  board.moveList(1,0)
#  board.moveList(3,5)
  board.printMoves
