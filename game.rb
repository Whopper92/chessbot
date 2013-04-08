#! /usr/bin/ruby

require 'state.rb'
require 'square.rb'
require 'move.rb'

  board = State.new()
  board.humanPlay
#  board.randomGame
  #board.printBoard
#  board.getState

=begin
  puts "\n"
  board.printBoard
  puts "\n"
  board.humanMove('e1-e2')
  board.printBoard
  puts "\n"

  board.humanMove('b4-c3')
  board.printBoard
  puts "\n"
  board.humanMove('a1-a2')
  board.printBoard
  puts "\n"
  board.humanMove('c3-d2')
  board.printBoard
  puts "\n"
  board.humanMove('d1-d2')
  board.printBoard
  puts "\n"
=end
#  puts "W"
#  testMove = Move.new(Square.new(4,0), Square.new(4,1), false)
#  board.move(testMove)
#  board.printBoard
#  puts "\n"
#  puts "B"
#  testMove = Move.new(Square.new(1,3), Square.new(2,2), false)
#  board.move(testMove)
#  board.printBoard
#  puts "\n"
#  testMove = Move.new(Square.new(3,0), Square.new(3,1), false)
#  newState = board.move(testMove)
#  board.printBoard
