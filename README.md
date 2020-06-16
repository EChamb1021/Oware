
Ouri.pl README File
--------------------------------------------------

The Ouri Board is displayed using the following interface: 


[[0],4,4,4,4,4,4]
[4,4,4,4,4,4,[0]]

Imagine you are looking at the board from a bird's eye view.  The bracketed number on the right is 
your score and the bracketed number on the left is your opponent's score.  The bottom 6 numbers are 
your pits and the top 6 numbers are your opponents pits.  Each number represents the number of seeds
currently in the pit.

So in the above example board, the score is 0-0, and all your pits and your opponents pits have 4 seeds 
in them.  This is the configuration of the board when the game begins.

The best_move_1(Board,M) predicate takes a game board as an argument and returns M, the best move for the 
player.  The best_move_1 predicate uses an algorithm which maximizes the number of points scored with the move
it selects.

Note: In the best_move_1 predicate, the board must be entered in the format of a list of length 12, where the first 6
elements represent the player's pits and the last 6 elements represent the opponent's pits.

Example: 

This board: [0,1,4,6,2,1,0,0,8,1,4,6]

translates to this board: [[Score],6,4,1,8,0,0]
			  [0,1,4,6,2,1,[Score]]

To play Ouri against the computer, run the predicate start_game(-p) if you want the computer to move first, and run the 
predicate start_game(-s) if you want the computer to move second.



To run the second best move algorithm, run best_move_2(Board,M) replacing board with a gameboard in the format mentioned above.
This algorithm makes a list of pits that have seeds, and randomly selects one of them.

To run the program in the command line, first open a terminal.  Then type "swipl" to start the prolog terminal.  Then navigate to 
the directory where thet ouri.pl file is saved and type "[ouri]." and hit enter.  Then you should be able to run any of the predicates
in the file.

To simulate a 6 game tournament between the two best move algorithms, run start_cpu_tournament.  Note this predicate has no arguments.

The results will be displayed in a list of length 6 where the index of the list represents the game and the outcome can be any of the following:

1 = CPU1 won

2 = CPU2 won

0 = Draw
