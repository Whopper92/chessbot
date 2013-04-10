#! /usr/bin/ruby

require './state.rb'
require './move.rb'

# I believe this class is simply a data structure to hold coordinates for
# many squares, one per objecct. Two instances of this class will exist in
# each instance of the Move class, which itself is held in some sort of array.
#[{move:(toSq,fromSq)},{move:(toSq,fromSq)},{move:(toSq,fromSq)} ]
class Square

  attr_reader :xPos, :yPos

  def initialize(x, y)
    @xPos = x
    @yPos = y
  end
end
