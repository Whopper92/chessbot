require 'spec_helper'
require File.expand_path('../../square.rb', __FILE__)

describe Square do

  before(:each) do
    @aSquare = Square.new(1, 2)
  end

  describe '#initialize' do
    it 'takes X and Y position arguments and creates a square at said coordinates' do
      @aSquare.xPos.should == 1
      @aSquare.yPos.should == 2
    end
  end
end
