#! /usr/bin/ruby

require 'net/telnet'
require File.expand_path('../../lib/state.rb', __FILE__)
require File.expand_path('../../lib/square.rb', __FILE__)
require File.expand_path('../../lib/move.rb', __FILE__)
require File.expand_path('../../lib/exceptions.rb', __FILE__)


class Client
  # A client interface to the IMC Server

  def connect
  # Connect to the IMC Server and login

    server = 'imcs.svcs.cs.pdx.edu'
    port   =  3589
    user   = 'rooky'
    pass   = 'chess'
    @imcs   = Net::Telnet::new("Host"       => server,
                               "Port"       => port,
                               "Prompt"     => //,
                               "Timeout"    => false,
                               "Output_log" => "output_log"
                              ) { |c| print c }
    @imcs.cmd("me #{user} #{pass}") { |c| print c }
  end

  def offer(time)
  # Offer a new game on the server. Accepts argument for player color
    @imcs.cmd("offer #{@color} #{time}") { |c| print c }
    gameLoop
  end

  def accept(gameID)
  # Accept an existing game on the server if game id specified in argument
    @imcs.cmd("accept #{gameID}") {|c| print c }
    gameLoop
  end

  def playGame
    puts "Enter 'offer <color>, <time>' or 'accept <game ID> <color>':"
    option = gets
    if option.match('offer')
      @color = option[6].chr
      time   = option[8..-1]
      self.connect
      offer(time)
    elsif option.match('accept')
      option = option.chomp!
      gameID = option[7..11]
      @color = option[-1].chr
      self.connect
      accept(gameID)
    else
      puts 'Invalid selection!'
    end
  end

  def looper
  # A loop to offer games
    puts "here"
    @color = 'W'
    time   = '5:00'
    self.connect
    offer(time)
  end

  def gameLoop
  # The main game loop
    @state = State.new
    turn = 0

    while @state.gameOver?(@state.board) == false do
      if @state.onMove.to_s == @color
        puts "It is my move!!!!!"
        if turn == 0 and @color == 'W'
          @imcs.waitfor("Match" => /\? /).each do |line|
            puts line
          end
          newMove = @state.tourneySendMove
          @imcs.cmd("#{newMove}") { |c| print c }
          turn += 1
        else
          newMove = @state.tourneySendMove
          @imcs.cmd("#{newMove}") { |c| print c }
        end
      else
          puts "waiting"
          @imcs.waitfor("Match" => /\? /).each do |line|
            puts line
            @move = line if line =~ /! .{2}-.{2}/
          end
          @state.tourneyGetMove(@move)
      end
    end

    puts "= #{@state.winner}"
  end
end
