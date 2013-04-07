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
  board.findAllMoves

  testMove = Move.new(Square.new(4,0), Square.new(4,1), false)
#  testMove = Move.new(Square.new(1,3), Square.new(2,2), false)
  newState = board.move(testMove)
  board.printBoard
