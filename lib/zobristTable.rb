#! /usr/bin/ruby

class ZobristTable

  def initialize
    # 30x13 array of long ints (30 squares by 13 piece types, including empty)
    @zobristKey = Array.new(30) { Array.new(13) }

    for i in 0..29
      for k in 0..12
        randNum = rand(10**10)
        while randNum.to_s.length != 10
          randNum = rand(11**11)
        end
        @zobristKey[i][k] = randNum
      end
    end
  end

  def keyLookUp(aState)
    # First, determine the key for the state
    key = getStateKey(aState)

    yIndex = 0
    xIndex = 0
    found = false
    @zobristKey.each do |y|
      y.each do |x|
        if key == x
          found = true
          break
        end
        xIndex += 1
      end
      break if found == true
      yIndex += 1
      xIndex = 0
    end
    if found == true
      return [xIndex, yIndex]
    else
      return nil
    end
  end

  def getStateKey(onMoveKey)
    # XORs every square to come up with the state key
      stateHash = 0
      for i in 0..29
        for k in 0..11
          stateHash = @zobristKey[i][k] ^ @zobristKey[i][k+1]
        end
      end
      return stateHash
  end

  def updateHash(x0, y0, x, y, whiteKey, playerKey, stateZKey)
    source0 = @zobristKey[y0][x0]    # Original source square before move
    source  = @zobristKey[y0][0]     # Empty source square following move
    dest0   = @zobristKey[y][x]      # Original dest square before move
    dest    = @zobristKey[y][x0]     # Updated dest square following move
    newHash = stateZKey ^ source0 ^ source ^ dest0 ^ dest ^ playerKey
    return newHash
  end
end
