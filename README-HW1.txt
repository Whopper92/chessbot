Homework 1: Discussion

My path through various solutions for the implementation of homework 1
was certainly interesting. Follows is a discussion of the various
decisions I made while completing this assignment.

1) The language
  I chose Ruby to implement this assignment in simply because Ruby is
  quite literally a "joy to program" in for me. I am definitely aware
  that Ruby will not get the same kind of performance as something like
  C, but I believe my comfort in the language was reason enough to select
  it.

  That being said, I also definitely chose Ruby to learn more of it, and
  thus far I have learned a ton. Before this class, I hadn't really ever
  done much in the language.

2) The board representation
  My first goal for representing the board was actually using bitboards.
  As can be seen in my git branch 'bitboards,' I had 12 working bitboards
  and a method to properly display it. While this method was simple enough
  for just displaying by use of AND's, OR's and XOR's, I found that moving
  forward, bitboards would just become too complex for me to effectively
  use and maintain for the rest of the assignment.

  My next idea was a single dimensional array with 'padding' around the
  'edges' to determine if a piece was stepping off of the board. This
  idea came from research on how some people implement full-sized chess
  engines. However, I quickly realized that this is totally unnecessary
  for minichess, as checking for out-of-bounds is trivial.

  Thus, my final and current board representation is a 2D-array, which
  makes writing and debugging much simpler and more understandable. The array
  is a 6x5 grid, which I decided to use based on the way the board is
  displayed.

3) MoveScan and MoveList implementation
  To generate an array of all valid moves, I followed the pseudocode
  pretty closely. Each 'move' is literally a Move object, all of which are
  stored in a single array. My Move objects each contain two Square
  objects, which hold the coordinates of a square. Another field I
  added later to the Move object is 'isCap,' which is true when
  the move results in a capture. I'm not sure if this is really
  necessary, but it seems like it could be useful later on, and
  I needed it to determine when a pawn can move diagonally.

4) Random Games and Human moves
  Surprisingly, the random game and human play games were quite
  easy to implement. My code is modular enough such that each
  method was trivially easy to make support both of these game
  types.

5) Interesting issues I ran into
  Besides ramming my head into the wall with bitboards, I also
  ran into the issue of trying to keep two representations of
  the same data in sync. With my first, single dimensional array,
  I needed a real grid system to more easily convert from array indexes
  to pseudo-2D array to chess strings. Luckily, I discovered how much
  trouble that grid was going to become fairly early on, which led me
  to convert the entire board representation into a nice grid itself.

6) Future considerations
  At the time of this writing, I am currently working on implementing a full
  rspec test suite, featuring Travis continuous integration. Hopefully these
  tests will not take too long to write and will save my many headaches down
  the road.
