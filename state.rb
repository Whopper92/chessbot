#! /usr/bin/ruby

require 'square.rb'
require 'move.rb'

class State

  def initialize
    @maxTurns = 80
    @board = [] # The board array
    self.newBoard
  end

  def printBoard
  # Print out a formatted version of the current state of the board

    board =  "#{@board[0 .. 4]}\n"\
             "#{@board[5 .. 9]}\n"\
             "#{@board[10..14]}\n"\
             "#{@board[15..19]}\n"\
             "#{@board[20..24]}\n"\
             "#{@board[25..29]}\n"
     puts "#{@turnCount} #{@onMove}"
     puts board
  end

  def getState
  # Reads in a full string representation of the board
  # Note: It is unclear as to where this board will come from, so this method
  # implements the read as if the data were in a file

    @newBoard  = []

    File.open('test_state.txt').each do |line|
      @newBoard << line[0...-1].split('')
    end

    updateState(@newBoard)
  end

  def updateState(curBoard)
  # Takes string from request called in getState to update the current board
  # based on a full string representation of the opponent's board

    @turnCount = curBoard[0][0]
    @onMove    = curBoard[0][2]

    x = 0
    y = 1
    while x < 25 do
      @board[x .. x+4] = curBoard[y][0..4]
      x += 5
      y += 1
    end
    assignRows
  end

  def newBoard
  # Reset all piece locations to create fresh board

    @onMove          = "W"
    @turnCount       = 0
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

    allSquares = 30
    i = 0
    while i < allSquares do
      case i
        when 0..4:
          @board << @blackKingSym if i == 0
          @board << @blackQueenSym if i == 1
          @board << @blackBishopSym if i == 2
          @board << @blackKnightSym if i == 3
          @board << @blackRookSym if i == 4
        when 5..9:
          @board << @blackPawnSym
        when 10..14:
          @board << '.'
        when 15..19:
          @board << '.'
        when 20..24:
          @board <<  @whitePawnSym
        when 25..29:
          @board << @whiteRookSym if i == 25
          @board << @whiteKnightSym if i == 26
          @board << @whiteBishopSym if i == 27
          @board << @whiteQueenSym if i == 28
          @board << @whiteKingSym if i == 29
      end
      i += 1
    end
    assignRows
  end

  def assignRows
  # Assign key indexes from the board array to convert (x,y) coordinates to
  # array indexes for quick lookup. To easily map with the (x,y) coordinate
  # system, the rows are actually the board array in reverse
    @xyGrid = []
    @xyGrid << @board[25..29]
    @xyGrid << @board[20..24]
    @xyGrid << @board[15..19]
    @xyGrid << @board[10..14]
    @xyGrid << @board[5 .. 9]
    @xyGrid << @board[0 .. 4]
  end

  def colorOf(x, y)
  # Determine the color a piece on a given square
    if ((@xyGrid[y][x]).to_s) == ((@xyGrid[y][x]).to_s).upcase
      return 'W'
    else
      return 'B'
    end
  end

  def moveScan(xInit, yInit, dx, dy, stopShort, capture)
  # This method is called many times by the moveList function,
  # which passes in every combination of movement directions for
  # a given piece for a given square position, many times over.
  x = xInit
  y = yInit
  c = colorOf(x,y)
  puts c

  end

  def moveList
  # Scans every position of the entire board to determine every valid
  # move in the current state
    self.moveScan(1, 0, 0, 1, false, true)
  end
end
