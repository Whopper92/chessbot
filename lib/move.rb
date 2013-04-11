#! /usr/bin/ruby

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

  # Return (x,y) coordinates from this move object
  # Accepts 'from' or 'to' strings to decode the desired square
  def decode(step)
    if step == 'from'
      [@fromSquare.xPos, @fromSquare.yPos]
    elsif step == 'to'
      [@toSquare.xPos, @toSquare.yPos]
    end
  end

  # Return a human-readable chess string representation of this move
  def to_s
    from = toChessMv(@fromSquare.xPos, @fromSquare.yPos)
    to   = toChessMv(@toSquare.xPos, @toSquare.yPos)
    "#{from}-#{to}"
  end
end
