#! /usr/bin/ruby

require 'state.rb'
require 'move.rb'

# I believe this class is simply a data structure to hold coordinates for
# many squares, one per objecct. Two instances of this class will exist in
# each instance of the Move class, which itself is held in some sort of array.
#[{move:(toSq,fromSq)},{move:(toSq,fromSq)},{move:(toSq,fromSq)} ]
class Square

  # x and y board coordinates
  @xPos # range: 0..4
  @yPos # range: 0..5

end
