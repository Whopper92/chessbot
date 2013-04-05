#! /usr/bin/ruby

require 'open3'

class State

  def initialize
    @maxTurns = 80
    @board = [] # The board array
    self.newBoard
  end

  # Method: printBoard
  # Print out a formatted version of the current state of the board
  def printBoard

    board =  "#{@board[20..24]}\n"\
             "#{@board[29..33]}\n"\
             "#{@board[38..42]}\n"\
             "#{@board[47..51]}\n"\
             "#{@board[56..60]}\n"\
             "#{@board[65..69]}\n"

     puts "#{@turnCount} #{@onMove}"
     puts board
  end

  # Method: getState
  # Reads in a full string representation of the board
  # Note: It is unclear as to where this board will come from, so this method
  # implements the read as if the data were in a file
  def getState
    @newBoard  = []

    File.open('test_state.txt').each do |line|
      @newBoard << line[0...-1].split('')
    end

    updateState(@newBoard)
  end

  # Method: updateBoard
  # Takes string from request called in getState to update the current board
  # based on a full string representation of the opponent's board
    def updateState(curBoard)
        @turnCount     = curBoard[0][0]
        @onMove        = curBoard[0][2]
        @board[20..24] = curBoard[1][0..4]
        @board[29..33] = curBoard[2][0..4]
        @board[38..42] = curBoard[3][0..4]
        @board[47..51] = curBoard[4][0..4]
        @board[56..60] = curBoard[5][0..4]
        @board[65..69] = curBoard[6][0..4]
    end

  # Method: newBoard
  # Reset all piece locations to create fresh board
  def newBoard

    @onMove    = "W"
    @turnCount = 0
    @whiteKingSym    = 'K'
    @whiteQueenSym   = 'Q'
    @whiteBishopSym  = 'B'
    @whiteKnightSym  = 'N'
    @whiteRookSym    = 'R'
    @whitePawnSym    = 'P'

    @blackKingSym    = 'k'
    @blackQueenSym   = 'q'
    @blackBishopSym  = 'b'
    @blackKnightSym  = 'n'
    @blackRookSym    = 'r'
    @blackPawnSym    = 'p'

    # The board consists of 30 valid squares in the ranges specified.
    # The rest of the squares comprise a double layer of 'invalid'
    # squares to more efficiently prevent out-of-bounds moves
    allSquares = 89
    i = 0

    while i < allSquares do
      case i
        when 20..24:
          @board << @blackKingSym if i == 20
          @board << @blackQueenSym if i == 21
          @board << @blackBishopSym if i == 22
          @board << @blackKnightSym if i == 23
          @board << @blackRookSym if i == 24
        when 29..33:
          @board << @blackPawnSym
        when 38..42:
          @board << '.'
        when 47..51: 
          @board << '.'
        when 56..60:
          @board <<  @whitePawnSym
        when 65..69:
          @board << @whiteRookSym if i == 65
          @board << @whiteKnightSym if i == 66
          @board << @whiteBishopSym if i == 67
          @board << @whiteQueenSym if i == 68
          @board << @whiteKingSym if i == 69
        else @board << 'x' # An invalid square
      end
      i += 1
    end
  end
end
