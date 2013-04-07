#! /usr/bin/ruby

require 'square.rb'
require 'move.rb'

class State

  def initialize
    @maxTurns = 80
    @moveList = [] # All moves valid from this state
    self.newBoard
  end

  def printBoard
  # Print out a formatted version of the current state of the board
    puts "#{@turnCount} #{@onMove}"
    y = 5
    while y > - 1
      for x in 0..4
        print @board[y][x]
        x += 1
      end
      print "\n"
      y -= 1
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

    @board = [
      ['R', 'N', 'B', 'Q', 'K'],
      ['P', 'P', 'P', 'P', 'P'],
      ['.', '.', '.', '.', '.'],
      ['.', '.', '.', '.', '.'],
      ['p', 'p', 'p', 'p', 'p'],
      ['k', 'q', 'b', 'n', 'r']
    ]

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

    x = 0, y = 0, z = 6
    while y < 6
      for x in 0..4
        @board[y][x] = curBoard[z][x]
      end
    y += 1
    z -= 1
    end
  end

  def updateBoard(x0, y0, x, y)
  # Update the board based on a single valid move
    fromPiece = @board[y0][x0]
    toPiece   = @board[y][x]  # This may be useful later to determine what was captured
    # Now update both positions on the board array
    @board[y0][x0] = '.'
    @board[y][x]   = fromPiece
    return @board
  end

  def move(aMove)
  # Accepts an argument of type move. If the move is valid, this method
  # returns a new state. Invalid moves result in an exception
  # Psuedocode:
=begin
  1) Is this move the same as a move in my list of all valid moves?
  2) Is the piece in the fromSq the same color as the color onMove?
  3)  If yes, replace the fromSq with a '.' and replace the toSq with the piece from fromSq
  4)  If no, throw exception
=end
    isValid = false
    @allMoves.each do |x|
      x.each do |y|
        isValid = true if y.to_s[/#{aMove}/]
      end
    end
    if isValid == true

      pos = aMove.decode('from')
      to  = aMove.decode('to')

      if @board[pos[1]][pos[0]].upcase == @board[pos[1]][pos[0]] and @onMove == 'W' # Valid white move
        updateBoard(pos[0], pos[1], to[0], to[1])
      elsif @board[pos[1]][pos[0]].upcase != @board[pos[1]][pos[0]] and @onMove == 'B' # Valid black move
        updateBoard(pos[0], pos[1], to[0], to[1])
      else # Player moving out of order - throw exception

      end
    end


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
      if @board[y][x].to_s != '.'
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
    p = @board[y][x].upcase
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
        @board[y][x].upcase == @board[y][x] ? dir = 1 : dir = -1
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
    #puts @allMoves
  end

  def colorOf(x, y)
  # Determine the color a piece on a given square
    if ((@board[y][x]).to_s) == ((@board[y][x]).to_s).upcase
      'W'
    else
      'B'
    end
  end

  def inBounds?(x, y)
    x > -1 and x < 5 and y > -1 and y < 6
  end
end
