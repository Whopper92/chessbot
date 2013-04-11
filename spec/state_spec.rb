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

  before :each do
    @aState.instance_variable_set :@board, [["R", "N", "B", "Q", "K"],
                                            ["P", "P", "P", "P", "P"],
                                            [".", ".", ".", ".", "."],
                                            [".", ".", ".", ".", "."],
                                            ["p", "p", "p", "p", "p"],
                                            ["k", "q", "b", "n", "r"]]
    @aState.instance_variable_set :@turnCount, 0
    @aState.instance_variable_set :@onMove, 'W'
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
=end

  describe '#decodeMvString' do
    it 'should return an (x,y) pair for a given chess move string' do
      result = @aState.decodeMvString('a1-a2')
      result.should be_an_instance_of Move
      result.instance_variable_get(:@fromSquare).xPos.should == 0
      result.instance_variable_get(:@fromSquare).yPos.should == 0
      result.instance_variable_get(:@toSquare).xPos.should == 0
      result.instance_variable_get(:@toSquare).yPos.should == 1
    end

    it 'should raise a MalformedMoveError if argument string length is not 5' do
      expect { @aState.decodeMvString('somestring')}.to raise_error MalformedMoveError
    end
  end

  describe '#gameOver?' do
    it 'should return true if either king is missing' do
      @aState.instance_variable_set :@turnCount, 10
      @aState.instance_variable_set :@board, [["R", "N", "B", "Q", "."],
                                              ["P", "P", "P", "P", "P"],
                                              [".", ".", ".", ".", "."],
                                              [".", ".", ".", ".", "."],
                                              ["p", "p", "p", "p", "p"],
                                              ["k", "q", "b", "n", "r"]]
      @aState.gameOver?.should == true
    end

    it 'should return true if the move count exceeds the maximum number of moves' do
      @aState.instance_variable_set :@turnCount, 81
      @aState.gameOver?.should == true
    end

    it 'should return false if both kings are alive and 40 moves have not passed' do
      @aState.instance_variable_set :@turnCount, 10
      @aState.instance_variable_set :@board, [["R", "N", "B", "Q", "K"],
                                              ["P", "P", "P", "P", "P"],
                                              [".", ".", ".", ".", "."],
                                              [".", ".", ".", ".", "."],
                                              ["p", "p", "p", "p", "p"],
                                              ["k", "q", "b", "n", "r"]]
      @aState.gameOver?.should == false
    end
  end

  describe '#validMove?' do
    it 'should return true if a valid move string is passed' do
      @aState.validMove?('a2-a3').should == true
    end

    it 'should return false if any invalid move string is passed' do
      @aState.validMove?('f7-g6').should == false
      @aState.validMove?('somestring').should == false
      @aState.validMove?('').should == false
    end
  end
end

