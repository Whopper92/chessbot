#! /usr/bin/ruby

require 'square.rb'
require 'move.rb'

class State

  def initialize
    @maxTurns = 80
    @board    = [] # The board array
    @moveList = [] # All moves valid from this state
    self.newBoard
  end

  def printBoard
  # Print out a formatted version of the current state of the board
    puts "#{@turnCount} #{@onMove}"
    i = 0
    while i < 30 do
      print @board[i .. i+4]
      print "\n"
      i += 5
    end
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
      'W'
    else
      'B'
    end
  end

  def inBounds?(x, y)
    x > -1 and x < 5 and y > 0 and y < 6
  end

  def moveScan(x0, y0, dx, dy, stopShort, capture)
  # This method is called many times by the moveList function,
  # which passes in every combination of movement directions for
  # a given piece for a given square position, many times over.
    x = x0
    y = y0
    c = colorOf(x,y)
    moves     = []
    validMove = []
    invalid   = ['!']
    loop do
      x += dx
      y += dy
      break if not inBounds?(x, y)
      if @xyGrid[y][x].to_s != '.'
        break if colorOf(x, y) == c  # Same color, so the move is invalid
        if capture == false
          break                        # We don't want to take this capture
        else
          stopShort = true             # the capture move is valid
        end
      end
      validMove = Move.new(Square.new(x0, y0), Square.new(x, y))
      moves << validMove
      break if stopShort == true
    end

    if moves != []
      return moves
    else
      return invalid
    end
  end

  def moveList(x, y)
  # GRID SYSTEM: rows are y values, starting at 0 from the bottom
  # Columns are x values, starting at 0 from the left
  # Finds every valid move for a given piece
    p        = @xyGrid[y][x].upcase
    temp     = []
    case p
      when 'K', 'Q'
        for dx in -1..1
          for dy in -1..1
            next if dx == 0 and dy == 0
            p == 'K' ? stopShort = true : stopShort = false
            capture = true
            temp = moveScan(x, y, dx, dy, stopShort, capture)
            temp.each do |a|
              @moveList << a if a != '!'
            end
          end
        end
      when 'R', 'B'

      when 'K'

      when 'P'
    end
    @moveList.each do |x|   # For testing
      puts x.to_s
    end
    puts "\n\n"
  end
end
