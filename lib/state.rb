#! /usr/bin/ruby

require File.expand_path('../square.rb', __FILE__)
require File.expand_path('../move.rb', __FILE__)
require File.expand_path('../exceptions.rb', __FILE__)

class State

  def initialize
    @maxTurns  = 80
    @moveList  = [] # All moves valid from this state
    @onMove    = "W"
    @turnCount = 0
    newBoard
    findAllMoves
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

    @onMove          = 'W'
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
    self.findAllMoves # Update valid move list
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
    isValid = false
    @allMoves.each do |x|
      x.each do |y|
        isValid = true if y.to_s[/#{aMove}/]
      end
    end
    begin
      if isValid == true
        pos = aMove.decode('from')
        to  = aMove.decode('to')
        if (@board[pos[1]][pos[0]].upcase == @board[pos[1]][pos[0]] and @onMove == 'W') or # Valid white move
           (@board[pos[1]][pos[0]].upcase != @board[pos[1]][pos[0]] and @onMove == 'B') # Valid black move
              updateBoard(pos[0], pos[1], to[0], to[1])
              findAllMoves  # update the valid move list
              @turnCount = @turnCount.to_i + 1
              @onMove == 'W' ? @onMove = 'B' : @onMove = 'W'
        else # Player moving out of order - throw exception
          raise WrongPlayerError
        end
      else # an invalid move
        raise InvalidMoveError
      end

      rescue WrongPlayerError => e
       puts "Encountered a move from the wrong player. Ignoring and maintaining current state."

      rescue InvalidMoveError => e
        puts "Encountered an invalid move. Ignoring and maintaining current state."
    end
  end

  def humanMove(mvString)
  # Accept a move string as an argument and attempts to make the
  # move, if valid
    humanMove = decodeMvString(mvString)
    move(humanMove)

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
        p == 'B' ? capture   = false : capture   = true
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
          capture   = true
          stopShort = false
          for i in 1..4
            getMv = moveScan(x, y, dx, dy, stopShort, capture)
            if getMv != nil
              getMv.each do |a|
                foundMoves << a
              end
            end
            dx,dy = -dy,dx
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
          dx,dy = -dy,dx
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
    if @board[y][x].to_s == @board[y][x].to_s.upcase and @board[y][x] != '.'
      return 'W'
    elsif @board[y][x].to_s != @board[y][x].to_s.upcase and @board[y][x] != '.'
      return 'B'
    else
      return 'empty'
    end
  end

  def inBounds?(x, y)
    if x > -1 and x < 5 and y > -1 and y < 6
      return true
    else
      return false
    end
  end

  def decodeMvString(mvString)
  # Decode a string of type 'a1-a2' into (x,y) coordinates
  # Returns a move object
    begin
      raise MalformedMoveError if mvString.length != 5
      values = {"a" => 0, "b" => 1, "c"=> 2, "d" => 3, "e" => 4}
      x0  = values["#{mvString[0].chr}"]
      y0  = mvString[1].chr.to_i - 1
      x    = values["#{mvString[3].chr}"]
      y    = mvString[4].chr.to_i - 1
      isCap = false

      newMove = Move.new(Square.new(x0, y0), Square.new(x, y), isCap)

      return newMove
    end
  end

  def randomGame
  # The bot will complete a single random game, picking
  # random moves for both sides
    while gameOver? == false do
      randomMove
      printBoard
      puts "\n"
    end
  end

  def humanPlay
  # Allow a human player to pick a color and play against the bot
    humanColor = ''
    botColor   = ''
    loop do
      puts "Welcome! Choose a color: W or B"
      humanColor = gets
      humanColor = humanColor.chomp!
      break if humanColor == 'W' or humanColor.to_s == 'B'
    end
    humanColor == 'W' ? botColor = 'B': botColor = 'W'

    puts "\n"
    printBoard
    puts "\n"

    # Game loop
    while gameOver? == false do
      if @onMove == humanColor
        loop do
          puts "Enter a move command: "
          @movePick = gets
          @movePick = @movePick.chomp!
          break if validMove?(@movePick)
        end
        humanMove(@movePick)
        puts "\n"
        printBoard
        puts "\n"
      else
        randomMove()
        puts "\n"
        printBoard
        puts "\n"
      end

    end
  end

  def randomMove()
  # Pick a random move based on the color of onMove
    pickMove = @allMoves.flatten.choice
    moved = false
    loop do
      if colorOf(pickMove.decode('from')[0], pickMove.decode('from')[1]) == @onMove
        move(pickMove)
        moved = true
      else
        pickMove = @allMoves.flatten.choice
      end
      break if moved == true
    end
  end

  def gameOver?
  # Determine if too many turns have passed or if either King has
  # been captured
    wKing = false
    bKing = false
    @board.flatten.each do |s|
      wKing = true if s.to_s == 'K'
      bKing = true if s.to_s == 'k'
    end
    if not wKing or not bKing or @turnCount > @maxTurns
      return true
    else
      return false
    end
  end

  def validMove?(aMove)
  # Validate a human move string to ensure it is sane
    return false if aMove.length != 5
    valCols = ['a', 'b', 'c', 'd', 'e']
    valRows = ['1', '2', '3', '4', '5', '6']
    if valCols.include? aMove[0].chr and valCols.include? aMove[3].chr and
       valRows.include? aMove[1].chr and valRows.include? aMove[4].chr
         return true
    else
         return false
    end
  end
end
