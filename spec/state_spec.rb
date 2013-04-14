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

      output = capture(:stdout) { @aState.printBoard }
      output.should ==
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

      @aState.updateBoard(1,0,0,2,@aState.instance_variable_get(:@board)).should ==
        [["R", ".", "B", "Q", "K"],
         ["P", "P", "P", "P", "P"],
         ["N", ".", ".", ".", "."],
         [".", ".", ".", ".", "."],
         ["p", "p", "p", "p", "p"],
         ["k", "q", "b", "n", "r"]]
    end

    it 'should promote a pawn that has reached the opposite side to a queen' do
      @aState.instance_variable_set :@board, [["R", "N", "B", ".", "K"],
                                              ["P", "P", "P", "p", "P"],
                                              [".", ".", ".", ".", "."],
                                              [".", ".", ".", ".", "."],
                                              ["p", "P", "p", "p", "p"],
                                              ["k", ".", "b", "n", "r"]]

      @aState.updateBoard(1,4,1,5, @aState.instance_variable_get(:@board)).should ==
        [["R", "N", "B", ".", "K"],
         ["P", "P", "P", "p", "P"],
         [".", ".", ".", ".", "."],
         [".", ".", ".", ".", "."],
         ["p", ".", "p", "p", "p"],
         ["k", "Q", "b", "n", "r"]]

      @aState.updateBoard(3,1,3,0, @aState.instance_variable_get(:@board)).should ==
        [["R", "N", "B", "q", "K"],
         ["P", "P", "P", ".", "P"],
         [".", ".", ".", ".", "."],
         [".", ".", ".", ".", "."],
         ["p", ".", "p", "p", "p"],
         ["k", "Q", "b", "n", "r"]]

    end
  end

  describe '#move' do
    validMove = Move.new(Square.new(0,1), Square.new(0,2))
    it 'should update the board if a valid move is passed' do
      @aState.should_receive(:updateBoard).with(0,1,0,2,@aState.instance_variable_get(:@board))
      @aState.move(validMove)
      @aState.instance_variable_get(:@turnCount).should == 1
      @aState.instance_variable_get(:@onMove).should == 'B'
    end
  end

  describe '#moveScan' do
    it 'should return nothing if there are no valid moves' do
      @aState.moveScan(0,0,0,1,true,true, (@aState.instance_variable_get(:@board))).should == nil
    end

    it 'should return an array of valid moves if there are any' do
    @aState.instance_variable_set :@board, [["R", "N", "B", "Q", "K"],
                                            [".", "P", "P", "P", "P"],
                                            [".", ".", ".", ".", "."],
                                            [".", ".", ".", ".", "."],
                                            ["p", "p", "p", "p", "p"],
                                            ["k", "q", "b", "n", "r"]]

      i = 1
      @aState.moveScan(0,0,0,1,false,true, (@aState.instance_variable_get(:@board))).each do |m|
        m.should be_an_instance_of Move
        m.to_s.should == 'a1-a2' if i == 1
        m.to_s.should == 'a1-a3' if i == 2
        m.to_s.should == 'a1-a4' if i == 3
        m.to_s.should == 'a1-a5' if i == 4
        i += 1
      end
    end
  end
=begin
  describe '#moveList' do

    it 'should call moveScan in every direction for a king' do
      @aState.should_receive(:moveScan).with(4,0,-1,-1,true,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(4,0,-1,0,true,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(4,0,-1,1,true,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(4,0,-0,-1,true,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(4,0,0,1,true,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(4,0,1,-1,true,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(4,0,1,0,true,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(4,0,1,1,true,true, @aState.instance_variable_get(:@board))
      @aState.moveList(4,0, @aState)
    end

    it 'should call moveScan in every direction for a queen' do
      @aState.should_receive(:moveScan).with(3,0,-1,-1,false,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(3,0,-1,0,false,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(3,0,-1,1,false,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(3,0,-0,-1,false,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(3,0,0,1,false,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(3,0,1,-1,false,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(3,0,1,0,false,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(3,0,1,1,false,true, @aState.instance_variable_get(:@board))
      @aState.moveList(3,0, @aState)

    end

    it 'should call moveScan in NSWE for a rook' do
      @aState.should_receive(:moveScan).with(0,0,1,0,false,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(0,0,0,1,false,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(0,0,-1,0,false,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(0,0,-0,-1,false,true, @aState.instance_variable_get(:@board))
      @aState.moveList(0,0, @aState.instance_variable_get(:@board))
    end

    it 'should call moveScan in every direction for a Bishop' do
      @aState.should_receive(:moveScan).with(2,0,1,0,true,false, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(2,0,0,1,true,false, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(2,0,-1,0,true,false, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(2,0,-0,-1,true,false, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(2,0,1,1,false,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(2,0,1,-1,false,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(2,0,-1,1,false,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(2,0,-1,-1,false,true, @aState.instance_variable_get(:@board))
      @aState.moveList(2,0, @aState.instance_variable_get(:@board))
    end

    it 'should call moveScan in eight directions for Knights' do
      @aState.should_receive(:moveScan).with(1,0,1,2,true,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(1,0,1,-2,true,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(1,0,-1,2,true,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(1,0,-1,-2,true,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(1,0,2,1,true,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(1,0,2,-1,true,true, @aState.instance_variable_get(:@board)
      @aState.should_receive(:moveScan).with(1,0,-2,1,true,true, @aState.instance_variable_get :@board)
      @aState.should_receive(:moveScan).with(1,0,-2,-1,true,true, @aState.instance_variable_get(:@board))
      @aState.moveList(1,0, @aState.instance_variable_get(:@board))
    end

    it 'should call moveScan in three directions for white Pawns' do
      @aState.should_receive(:moveScan).with(0,1,0,1,true,false, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(0,1,-1,1,true,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(0,1,1,1,true,true, @aState.instance_variable_get(:@board))
      @aState.moveList(0,1, @aState.instance_variable_get(:@board))
    end

    it 'should call moveScan in three directions for black Pawns' do
      @aState.should_receive(:moveScan).with(0,4,0,-1,true,false, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(0,4,-1,-1,true,true, @aState.instance_variable_get(:@board))
      @aState.should_receive(:moveScan).with(0,4,1,-1,true,true, @aState.instance_variable_get(:@board))
      @aState.moveList(0,4, @aState.instance_variable_get(:@board))

    end

  end
=end
  describe '#colorOf' do
    it 'should return the proper color of the piece on a given board index' do
      @aState.colorOf(0,0).should == 'W'
      @aState.colorOf(0,4).should == 'B'
      @aState.colorOf(2,2).should == 'empty'
    end
  end

  describe '#inBounds?' do
    it 'should return true if argument coordinates are in bounds' do
      @aState.inBounds?(0,5).should == true
      @aState.inBounds?(-2,0).should == false
    end
  end

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
      @aState.gameOver?(@aState.instance_variable_get(:@board)).should == true
    end

    it 'should return true if the move count exceeds the maximum number of moves' do
      @aState.instance_variable_set :@turnCount, 81
      @aState.gameOver?((@aState.instance_variable_get(:@board))).should == true
    end

    it 'should return false if both kings are alive and 40 moves have not passed' do
      @aState.instance_variable_set :@turnCount, 10
      @aState.instance_variable_set :@board, [["R", "N", "B", "Q", "K"],
                                              ["P", "P", "P", "P", "P"],
                                              [".", ".", ".", ".", "."],
                                              [".", ".", ".", ".", "."],
                                              ["p", "p", "p", "p", "p"],
                                              ["k", "q", "b", "n", "r"]]
      @aState.gameOver?((@aState.instance_variable_get(:@board))).should == false
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
