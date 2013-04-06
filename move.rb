#! /usr/bin/ruby

require 'state.rb'
require 'square.rb'

# I believe this class is no more than a small data structure to hold
# a single move. A large array will hold many of them in state.
class Move

  # Theory: These fields will hold objects of type square
  @fromSquare
  @toSquare

  def initialize(toSq, fromSq)
    @fromSquare = fromSq
    @toSquare = toSq
  end
end
