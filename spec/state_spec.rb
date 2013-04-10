require 'spec_helper'
require 'stringio'
require File.expand_path('../../lib/state.rb', __FILE__)
require File.expand_path('../../lib/move.rb', __FILE__)
require File.expand_path('../../lib/square.rb', __FILE__)
require File.expand_path('../../lib/exceptions.rb', __FILE__)

def capture(*streams)
  streams.map! { |stream| stream.to_s }
  begin
    result = StringIO.new
    streams.each { |stream| eval "$#{stream} = result" }
    yield
  ensure
    streams.each { |stream| eval("$#{stream} = #{stream.upcase}") }
  end
  result.string
end

describe State do

  before :all do
    @aState    = State.new
  end

  describe '#initialize' do
    it 'should initialize a new board array' do
      @aState.should be_an_instance_of State
      @aState.instance_variable_get(:@maxTurns).should == 80
      @aState.instance_variable_get(:@moveList).should == []
    end
  end

  describe '#printBoard' do
    it 'should print a formatted version of the current board state' do

      @output = capture(:stdout) { @aState.printBoard }
      @output.should ==
      "#{@aState.instance_variable_get(:@turnCount)} #{@aState.instance_variable_get(:@onMove)}\n"\
        "kqbnr\n"\
        "ppppp\n"\
        ".....\n"\
        ".....\n"\
        "PPPPP\n"\
        "RNBQK\n"
    end
  end

  describe '#updateBoard' do
    it 'should update the board array based on a valid move' do

      @aState.updateBoard(1,0,0,2).should ==
        [["R", ".", "B", "Q", "K"],
         ["P", "P", "P", "P", "P"],
         ["N", ".", ".", ".", "."],
         [".", ".", ".", ".", "."],
         ["p", "p", "p", "p", "p"],
         ["k", "q", "b", "n", "r"]]
    end
  end

=begin
  describe '#move' do
    it 'should raise an invalid move error if invalid input is received' do

    end
  end

  describe '#humanMove' do

  end

  describe '#moveScan' do

  end

  describe '#moveList' do

  end

  describe '#findAllMoves' do

  end

  describe '#colorOf' do

  end

  describe '#inBounds?' do

  end

  describe '#decodeMvString' do

  end

  describe '#randomGame' do

  end

  describe '#humanPlay' do

  end

  describe '#randomMove' do

  end

  describe '#gameOver?' do

  end

  describe '#validMove?' do

  end
=end
end

