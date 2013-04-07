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

  def getState
  # Reads in a full string representation of the board
  # Note: It is unclear as to where this board will come from, so this method
  # implements the read as if the data were in a file

    @newBoard  = []
    File.open('test_state.txt').each do |line|
      @newBoard << line[0...-1].split('')
    end

    writeBoard(@newBoard)
  end

  def writeBoard(curBoard)
  # Takes string from request called in getState to update the current board
  # based on a full string representation of the opponent's board

    @turnCount = curBoard[0][0]
    @onMove    = curBoard[0][2]

    x = 0
    y = 1
    while x < 30 do
      @board[x .. x+4] = curBoard[y][0..4]
      x += 5
      y += 1
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


  def moveScan(x0, y0, dx, dy, stopShort, capture)
  # This method is called many times by the moveList method,
  # which passes in every combination of movement directions for
  # a given piece for a given square position.
    x = x0
    y = y0
    c = colorOf(x,y)
    moves     = []
    validMove = []
    isCap     = false
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
          isCap     = true
        end
      end
      validMove = Move.new(Square.new(x0, y0), Square.new(x, y), isCap)
      moves << validMove
      break if stopShort == true
    end

    return moves if moves != []
  end

  def moveList(x, y)
  # GRID SYSTEM: rows are y values, starting at 0 from the bottom
  # Columns are x values, starting at 0 from the left
  # Finds every valid move for a given piece
    p          = @xyGrid[y][x].upcase
    foundMoves = []
    case p
      when 'K', 'Q'
        for dx in -1..1
          for dy in -1..1
            next if dx == 0 and dy == 0
            p == 'K' ? stopShort = true : stopShort = false
            capture = true
            getMv = moveScan(x, y, dx, dy, stopShort, capture)
            if getMv != nil
              getMv.each do |a|
                foundMoves << a
              end
            end
          end
        end
        return foundMoves

      when 'R', 'B'
        dx = 1
        dy = 0
        p == 'B' ? stopShort = true : stopShort = false
        capture = true
        for i in 1..4
          getMv = moveScan(x, y, dx, dy, stopShort, capture)
          if getMv != nil
            getMv.each do |a|
              foundMoves << a
            end
          end
          dx,dy = dy,dx
          dy = -dy
        end
        if p == 'B'
          dx        = 1
          dy        = 1
          stopShort = false
          for i in 1..4
            getMv = moveScan(x, y, dx, dy, stopShort, capture)
            if getMv != nil
              getMv.each do |a|
                foundMoves << a
              end
            end
            dx,dy = dy,dx
            dy = -dy
          end
        end
        return foundMoves

      when 'N'
        dx        = 1
        dy        = 2
        stopShort = true
        for i in 1..4
          getMv = moveScan(x, y, dx, dy, stopShort, capture)
          if getMv != nil
            getMv.each do |a|
              foundMoves << a
            end
          end
          dx,dy = dy,dx
          dy = -dy
        end

        dx = -1
        dy - 2
        for i in 1..4
          getMv = moveScan(x, y, dx, dy, stopShort, capture)
          if getMv != nil
            getMv.each do |a|
              foundMoves << a
            end
          end
          dx,dy = dy,dx
          dy = -dy
        end
        return foundMoves

      when 'P'
        checkList  = []
        @xyGrid[y][x].upcase == @xyGrid[y][x] ? dir = 1 : dir = -1
        stopShort = true
        getMv = moveScan(x, y, -1, dir, stopShort, capture)  # See if a capture diag-left exists
        if getMv != nil
          getMv.each do |a|
            checkList << a
          end
        end
        if checkList.length == 1 and checkList[0].isCapture == true
          foundMoves << checkList
        end
        checkList = []

        getMv = moveScan(x, y, 1, dir, stopShort, capture)  # Now see if a capture diag-right exists
        if getMv != nil
          getMv.each do |a|
            checkList << a
          end
        end
        if checkList.length == 1 and checkList[0].isCapture == true
          foundMoves << checkList
        end
        checkList = []

        capture = false                                    # Lastly, see if the pawn can move forward
        getMv = moveScan(x, y, 0, dir, stopShort, capture)
        if getMv != nil
          getMv.each do |a|
            foundMoves << a
          end
        end
        return foundMoves
    end
  end

  def findAllMoves
    moves     = []
    @allMoves = []

    for y in 0..5
      for x in 0..4
        moves << moveList(x, y)
      end
    end

    moves.each do |a|
      @allMoves << a if a != [] and a != nil
    end
    puts @allMoves
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
    x > -1 and x < 5 and y > -1 and y < 6
  end
end
