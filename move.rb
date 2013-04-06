#! /usr/bin/ruby

require 'state.rb'
require 'square.rb'

# I believe this class is no more than a small data structure to hold
# a single move. A large array will hold many of them in state.
class Move

  def initialize(fromSq, toSq)
    @fromSquare = fromSq
    @toSquare   = toSq
  end

  def to_s
    return "#{@fromSquare.getX},#{@fromSquare.getY}-#{@toSquare.getX},#{@toSquare.getY}"
  end
end
