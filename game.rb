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
  board.moveList(4,0)
