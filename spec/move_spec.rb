require 'spec_helper'
require File.expand_path('../../lib/move.rb', __FILE__)
require File.expand_path('../../lib/square.rb', __FILE__)

describe Move do

  before :all do
    @aMove = Move.new(Square.new(0, 0), Square.new(1, 1), false)
  end

  describe '#initialize' do
    it 'should take two Squares and a capture boolean value and creates a move object' do
      @aMove.isCapture.should == false
    end
  end

  describe '#toChessMv' do
    it 'should convert argument coordinates x,y into a chess movement string' do
      @aMove.toChessMv(0, 0).should == 'a1'
      @aMove.toChessMv(1, 1).should == 'b2'
    end
  end

  describe '#decode' do
    it 'should return the x and y coordinates from the specified square object' do
      @aMove.decode('from').should == [0, 0]
      @aMove.decode('to').should == [1, 1]
    end
  end

  describe '#to_s' do
    it 'should return a human readable chess string for this object' do
      @aMove.to_s.should == 'a1-b2'
    end
  end

end
