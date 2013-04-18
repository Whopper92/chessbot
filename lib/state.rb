#! /usr/bin/ruby

require File.expand_path('../square.rb', __FILE__)
require File.expand_path('../move.rb', __FILE__)
require File.expand_path('../exceptions.rb', __FILE__)

class State

  def initialize
    @maxTurns        = 80
    @maxSearchTime   = 1        # Time limit for negamax move search
    @onMove          = "W"
    @OnMoveInt       = 1        # Used for negamax negation
    @turnCount       = 0
    newBoard
    @allMoves       = findPlayerMoves(@board, @onMoveInt) # A list of all valid moves from this state
  end

  def printBoard
  # Print out a formatted version of the current state of the board
    puts "\n"
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
    puts "\n"
  end

  def newBoard
  # Reset all piece locations to create fresh board

    @onMove          = 'W'
    @onMoveInt       = 1
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
    @newBoard  = []
    File.open('data/test_state.txt').each do |line|
      @newBoard << line[0...-1].split('')
    end

    writeBoard(@newBoard)
  end

  def writeBoard(curBoard)
  # Takes string from request called in getState to update the current board
  # based on a full string representation of a board
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
    @allMoves = findPlayerMoves(@board, @onMoveInt) # Update valid move list
  end

  def updateBoard(x0, y0, x, y, aState)
  # Update the board based on a single valid move
    fromPiece = aState[y0][x0]
    toPiece   = aState[y][x]

    # If a pawn makes it the the opposite side of the board, promote to queen
    if fromPiece == 'P' and y == 5
      fromPiece = 'Q'
    elsif fromPiece == 'p' and y == 0
      fromPiece = 'q'
    end

    # Now update both positions on the board array
    aState[y0][x0] = '.'
    aState[y][x]   = fromPiece
    return aState
  end

  def randomGame
  # The bot will complete a single random game, picking
  # random moves for both sides
    depth = 2   # For testing negamax depths
    while gameOver?(@board) == false do
      botMove(depth)
      printBoard
      depth == 2 ? depth = 3 : depth = 2
    end
  end

  def humanPlay
  # Allow a human player to pick a color and play against the bot
    humanColor = ''
    botColor   = ''
    depth      = 3
    loop do
      puts "Welcome! Choose a color: W or B"
      humanColor = gets
      humanColor = humanColor.chomp!
      break if humanColor == 'W' or humanColor.to_s == 'B'
    end
    humanColor == 'W' ? botColor = 'B': botColor = 'W'
    printBoard
    # Game loop
    while gameOver?(@board) == false do
      if @onMove == humanColor
        loop do
          puts "Enter a move command: "
          @movePick = gets
          @movePick = @movePick.chomp!
          break if validMove?(@movePick)
        end
        humanMove(@movePick)
        printBoard
      else
        botMove(depth)
        printBoard
      end
    end
  end

  def botMove(depth)
  # Finds the bests move for the bot given some time constraint and executes said move

    @onMove == 'W' ? color = 1 : color = -1
    @nodes = 0
    maxSearchDepth = 2                                     # Start at search depth 1
    beginning   = Time.now
    currentTime = Time.now - beginning

    while currentTime < @maxSearchTime
      currentTime = Time.now - beginning
      negamax(@board, 0, color, beginning, maxSearchDepth)
      #puts "Reached depth: #{maxSearchDepth}"
      maxSearchDepth += 1                                  # Search another level if we have time
    end
    puts "\nChecked #{@nodes} nodes in #{Time.now - beginning} seconds.\n\n"
    puts @bestMove
    move(@bestMove)
  end

  def humanMove(mvString)
  # Accept a move string as an argument and attempts to make the move, if valid
    humanMove = decodeMvString(mvString)
    move(humanMove)
    score = scoreGen(@board)
    puts score
  end

  def moveScan(x0, y0, dx, dy, stopShort, capture, aState)
  # This method is called many times by the moveList method,
  # which passes in every combination of movement directions for
  # a given piece for a given square position.
    x = x0
    y = y0
    c = colorOf(x,y, aState)
    moves     = []
    validMove = []
    loop do
      x += dx
      y += dy
      break if not inBounds?(x, y)
      if aState[y][x].to_s != '.'
        break if colorOf(x, y, aState) == c  # Same color, so the move is invalid
        if capture == false
          break                              # We don't want to take this capture
        else
          stopShort = true                   # the capture move is valid
        end
      end
      validMove = Move.new(Square.new(x0, y0), Square.new(x, y))
      moves << validMove
      break if stopShort == true
    end
    return moves if moves != []
  end

  def moveList(x, y, aState)
  # GRID SYSTEM: rows are y values, starting at 0 from the bottom
  # Columns are x values, starting at 0 from the left
  # Finds every valid move for a given piece
    p = aState[y][x].upcase
    foundMoves = []
    case p
      when 'K', 'Q'
        for dx in -1..1
          for dy in -1..1
            next if dx == 0 and dy == 0
            p == 'K' ? stopShort = true : stopShort = false
            capture = true
            getMv = moveScan(x, y, dx, dy, stopShort, capture, aState)
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
          getMv = moveScan(x, y, dx, dy, stopShort, capture, aState)
          if getMv != nil
            getMv.each do |a|
              foundMoves << a
            end
          end
          dx,dy = -dy,dx
        end
        if p == 'B'
          dx        = 1
          dy        = 1
          capture   = true
          stopShort = false
          for i in 1..4
            getMv = moveScan(x, y, dx, dy, stopShort, capture, aState)
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
        capture   =  true
        for i in 1..4
          getMv = moveScan(x, y, dx, dy, stopShort, capture, aState)
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
          getMv = moveScan(x, y, dx, dy, stopShort, capture, aState)
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
        aState[y][x].upcase == aState[y][x] ? dir = 1 : dir = -1
        stopShort = true
        capture   = true
        getMv = moveScan(x, y, -1, dir, stopShort, capture, aState)  # See if a capture diag-left exists
        if getMv != nil
          getMv.each do |a|
            colorPawn   = colorOf(a.decode('from')[0], a.decode('from')[1], aState)
            colorTarget = colorOf(a.decode('to')[0], a.decode('to')[1], aState)
            if colorTarget != 'empty' and colorPawn != colorTarget  # a valid capture
              foundMoves << a
            end
          end
        end

        getMv = moveScan(x, y, 1, dir, stopShort, capture, aState)  # Now see if a capture diag-right exists
        if getMv != nil
          getMv.each do |a|
            colorPawn   = colorOf(a.decode('from')[0], a.decode('from')[1], aState)
            colorTarget = colorOf(a.decode('to')[0], a.decode('to')[1], aState)
            if colorTarget != 'empty' and colorPawn != colorTarget  # a valid capture
              foundMoves << a
            end
          end
        end

        capture = false                                    # Lastly, see if the pawn can move forward
        getMv = moveScan(x, y, 0, dir, stopShort, capture, aState)
        if getMv != nil
          getMv.each do |a|
            foundMoves << a
          end
        end
        return foundMoves
    end
  end

  def negamax(aState, depth, color, beginTime, maxSearchDepth)
    # Arguments: a board state, a starting depth, a color, a time limit, and maximum search depth
    # The color argument is taken as either 1 for white or -1 for black, and
    # is used to generate all valid moves for either player at a given state

    currentTime = Time.now - beginTime
    if gameOver?(aState) or depth > maxSearchDepth or currentTime >= @maxSearchTime
      @nodes += 1
      return color * scoreGen(aState)
    end

    bestValue  = -20000
    stateMoves = findPlayerMoves(aState, color)
    color == 1 ? bugCol = 'white' : bugCol = 'black'

    stateMoves.flatten.each do |m|
      @nodes += 1 # Stats: determine how many states are checked
      # Useful debugging info. Append to a file to check calls
      #      puts "#{bugCol}: I am trying move: #{m}--->" if depth == 0
      #      puts "    #{bugCol}: I am trying move:  #{m}---> #{bestValue}" if depth == 1
      #      puts "        #{bugCol}: I am trying move:  #{m}---> #{bestValue}" if depth == 2
      #      puts "            #{bugCol}: I am trying move:  #{m}---> #{bestValue}" if depth == 3
      testState = checkState(aState, m)
      score = -(negamax(testState, depth + 1, -color, beginTime, maxSearchDepth))
      if score > bestValue
        bestValue = score
        @bestMove = m if depth == 0
      end
    end
    return bestValue
  end

  def move(aMove)
  # Accepts arguments of type move and type state. If the move is valid, this method
  # returns a new state. Invalid moves result in an exception
    isValid = false
    @allMoves.flatten.each do |m|
      isValid = true if m.to_s[/#{aMove}/]
    end
    begin
      if isValid == true
        pos = aMove.decode('from')
        to  = aMove.decode('to')
        updateBoard(pos[0], pos[1], to[0], to[1], @board)
        @onMove == 'W' ? @onMove = 'B' : @onMove = 'W'
        @onMove == 'W' ? @onMoveInt = 1 : @onMoveInt = -1
        @allMoves = findPlayerMoves(@board, @onMoveInt)  # update the valid move list
        @turnCount = @turnCount.to_i + 1
      else # an invalid move
        raise InvalidMoveError
      end

      rescue InvalidMoveError => e
        puts "Encountered an invalid move. Ignoring and maintaining current state."
    end
  end

  def findPlayerMoves(aState, color)
  # Accepts a 1 for white or -1 for black and returns a list of valid moves for that player
    moves            = []
    validPlayerMoves = []

    for y in 0..5
      for x in 0..4
        moves << moveList(x, y, aState)
      end
    end

    moves.flatten.each do |m|
      if m != nil and m != []
        x = m.decode('from')[0]
        y = m.decode('from')[1]
        if color == 1
          if (aState[y][x].upcase == aState[y][x]) # Valid white move
            validPlayerMoves << m
          end
        elsif color == -1
          if (aState[y][x].upcase != aState[y][x]) # Valid black move
            validPlayerMoves << m
          end
        end
      end
    end
    return validPlayerMoves
  end

  def checkState(aState, aMove)
  # Returns a state that would exist should the move argument be taken
    testBoard = Marshal.load(Marshal.dump(aState))
    x0 = aMove.decode('from')[0]
    y0 = aMove.decode('from')[1]
    x  = aMove.decode('to')[0]
    y  = aMove.decode('to')[1]
    updatedState = updateBoard(x0, y0, x, y, testBoard)
    return updatedState
  end

  def scoreGen(aState)
  # Returns the score of a state the will exist if the given move is executed.
  # The score value is the score of the state that the opponent will receive,
  # so the lower the number the 'better' for the side onMove

    # Generate a score for this state --- enemy score - my score
    whiteScore = 0
    blackScore = 0

    aState.flatten.each do |p|
      case p
        when 'P'
          whiteScore += 100
        when 'Q'
          whiteScore += 900
        when 'K'
          whiteScore += 10000
        when 'B'
          whiteScore += 300
        when 'N'
          whiteScore += 300
        when 'R'
          whiteScore += 500
        when 'p'
          blackScore -= 100
        when 'q'
          blackScore -= 900
        when 'k'
          blackScore -= 10000
        when 'b'
          blackScore -= 300
        when 'n'
          blackScore -= 300
        when 'r'
          blackScore -= 500
      end
    end
    stateScore = whiteScore + blackScore
    return stateScore
  end

  def colorOf(x, y, aState)
  # Determine the color a piece on a given square
    if aState[y][x].to_s == aState[y][x].to_s.upcase and aState[y][x] != '.'
      return 'W'
    elsif aState[y][x].to_s != aState[y][x].to_s.upcase and aState[y][x] != '.'
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

  def gameOver?(aState)
  # Determine if too many turns have passed or if either King has
  # been captured
    wKing = false
    bKing = false
    aState.flatten.each do |s|
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

      newMove = Move.new(Square.new(x0, y0), Square.new(x, y))
      return newMove
    end
  end
end
