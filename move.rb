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

  # Convert from (x,y) coordinates to move string coordinates
  def toChessMv(x,y)
    col = ['a', 'b', 'c', 'd', 'e'][x]
    row = y+1
    col + row.to_s
  end

  def to_s
    from = toChessMv(@fromSquare.xPos, @fromSquare.yPos)
    to   = toChessMv(@toSquare.xPos, @toSquare.yPos)
    "#{from}-#{to}"
  end
end
