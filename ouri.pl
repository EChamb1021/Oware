%||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
%Oware
%Evan Chambers
%Tuesday, June 2nd, 2020

%This predicate slices a list based on the start and end index given
slice(L,Start,End,R) :-

    once(slice_helper(L,Start,End,R)).


% Helper function which handles the case where the all the elements from
% start index to end index have been visited
slice_helper(_,0,-1,X) :-
    X = [].

% Helper function which handles the case where the end of the list is
% reached, ending the recursion
slice_helper([],_,_,X) :-
    X = [].

% Helper Function which handles the case where the first element to be
% added to the result list (start index) is reached
slice_helper([H|T],0,End,R) :-
    NewEnd is End - 1,
    once(slice_helper(T,0,NewEnd,Z)),
    append([H],Z,R).

% Helper function which handles the Case where the start index has not
% been reached yet.
slice_helper([_|T],Start,End,R) :-
    NewStart is Start - 1,
    NewEnd is End - 1,
    once(slice_helper(T,NewStart,NewEnd,R)).

%Setting up board for the turn
create_board(Pit,Board,B) :-
    slice(Board,0,Pit-1,First),
    slice(Board,Pit,11,Second),
    append(Second,First,B).

%Helper function for distributing the seeds around the board
distribute_seeds(S,[],NB,R) :-
    distribute_seeds(S,NB,[],R).

distribute_seeds(0,B,NB,R) :-
    append([0|NB],B,R).

distribute_seeds(S,[H|T],NB,R) :-
    E is H+1,
    append(NB,[E],Board),
    NS is S - 1,
    distribute_seeds(NS,T,Board,R).

%Distributes the seeds around the board
distribute([Seeds|Board],R) :-
    once(distribute_seeds(Seeds,Board,[],R)).

%Given a pit to take from, return the board after the turn
possible_turn(Pit,Board,R) :-
    Pit =< 5,
    create_board(Pit,Board,Arrangement),
    distribute(Arrangement,SB),
    slice(SB,0,11-Pit,Back),
    slice(SB,12-Pit,11,Front),
    append(Front,Back,R).

%Count the occurences of a given element in a list
count_elements([],_,0).

count_elements([X|T],X,Y) :-
    !,
    count_elements(T,X,Z),
    Y is 1+Z.

count_elements([_|T],X,Z) :-
    count_elements(T,X,Z).

% Given a board calculates how many points should be scored on the
% opponent's side
total_score(Board,S) :-
    slice(Board,6,11,Opponent),
    count_elements(Opponent,2,NumTwos),
    count_elements(Opponent,3,NumThrees),
    A is NumTwos * 2,
    B is NumThrees * 3,
    S is A + B.



%Create a list of the seeds obtained from picking up each possible pit
score_list(Board,FL) :-
    possible_turn(0,Board,Pit1),
    total_score(Pit1,Pit1Score),
    append([Pit1Score],[],L1),
    possible_turn(1,Board,Pit2),
    total_score(Pit2,Pit2Score),
    append(L1,[Pit2Score],L2),
    possible_turn(2,Board,Pit3),
    total_score(Pit3,Pit3Score),
    append(L2,[Pit3Score],L3),
    possible_turn(3,Board,Pit4),
    total_score(Pit4,Pit4Score),
    append(L3,[Pit4Score],L4),
    possible_turn(4,Board,Pit5),
    total_score(Pit5,Pit5Score),
    append(L4,[Pit5Score],L5),
    possible_turn(5,Board,Pit6),
    total_score(Pit6,Pit6Score),
    append(L5,[Pit6Score],FL).

% True if the opponent only has zeros on their side, in which case the
% player must move in a way that gives the opponent seeds
zeros_only(Board) :-
    slice(Board,6,11,OpponentSide),
    list_to_set(OpponentSide,[0]).

%Calculates number of seeds the opponent would receive after a turn
num_seeds(Board,S) :-
    slice(Board,6,11,Opponent),
    sum_list(Opponent,S).

%Gives the opponent seeds if they have none
create_turn(Board,FL) :-
    possible_turn(0,Board,Pit1),
    num_seeds(Pit1,Pit1Score),
    append([Pit1Score],[],L1),
    possible_turn(1,Board,Pit2),
    num_seeds(Pit2,Pit2Score),
    append(L1,[Pit2Score],L2),
    possible_turn(2,Board,Pit3),
    num_seeds(Pit3,Pit3Score),
    append(L2,[Pit3Score],L3),
    possible_turn(3,Board,Pit4),
    num_seeds(Pit4,Pit4Score),
    append(L3,[Pit4Score],L4),
    possible_turn(4,Board,Pit5),
    num_seeds(Pit5,Pit5Score),
    append(L4,[Pit5Score],L5),
    possible_turn(5,Board,Pit6),
    num_seeds(Pit6,Pit6Score),
    append(L5,[Pit6Score],FL).



%Finds the move that results in the most seeds gained by the player.
best_move_(Board,M) :-
    zeros_only(Board),
    create_turn(Board,L),
    max_list(L,MaxScore),
    nth1(M,L,MaxScore),
    nth1(M,Board,Seeds),
    Seeds =\= 0.


best_move_(Board,M) :-
    score_list(Board,L),
    max_list(L,MaxScore),
    nth1(M,L,MaxScore),
    nth1(M,Board,Seeds),
    Seeds =\= 0.

% First Algorithm which determines the best move based on how many
% potential points can be scored
best_move_1(Board,M) :-
   once(best_move_(Board,M)).

%||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

%CPU vs Human

%displays the game board on the screen (interface)
display_board(PlayerScore,CPUScore,Board) :-
    slice(Board,0,5,PlayerPits),
    slice(Board,6,11,CPUPits),
    reverse(CPUPits,PitsFromAbove),
    append([[CPUScore]],PitsFromAbove,CPUSide),
    append(PlayerPits,[[PlayerScore]],PlayerSide),
    write(CPUSide),nl,
    write(PlayerSide),nl.

% Given two boards, returns a new list of pits which have changed during
% the turn
difference([],[],Change,R) :-
    R = Change.

difference([H1|T1],[H2|T2],Change,R) :-
    H1 =:= H2,
    difference(T1,T2,Change,R).


difference([H1|T1],[H2|T2],Change,R) :-
    H1 =\= H2,
    append(Change,[H2],NewChange),
    difference(T1,T2,NewChange,R).

% When points are scored, replace the pit with the value zero in the
% list
replace([],[],Update,R) :-
    R = Update.

replace([H1|T1],[2|T2],Update,R) :-
    H1 =\= 2,
    difference([H1|T1],[2|T2],[],Diff),
    (   last(Diff,2) ; last(Diff,3)),
    append(Update,[0],NewUpdate),
    replace(T1,T2,NewUpdate,R).

replace([H1|T1],[3|T2],Update,R) :-
    H1 =\= 3,
    difference([H1|T1],[3|T2],[],Diff),
    (   last(Diff,2) ; last(Diff,3)),
    append(Update,[0],NewUpdate),
    replace(T1,T2,NewUpdate,R).

replace([_|T1],[H2|T2],Update,R) :-
    append(Update,[H2],NewUpdate),
    replace(T1,T2,NewUpdate,R).


clear_pits(Old,New,Update) :-
    slice(Old,6,11,OldOpponent),
    slice(New,6,11,NewOpponent),
    slice(New,0,5,NewPlayerSide),
    once(replace(OldOpponent,NewOpponent,[],R)),
    append(NewPlayerSide,R,Update).


% Given a board before the turn and the board after a turn, determine
% what the player's new score should be
get_score(OldBoard,NewBoard,Score,NewScore) :-
    slice(OldBoard,6,11,OldOpponentSide),
    slice(NewBoard,6,11,NewOpponentSide),
    difference(OldOpponentSide,NewOpponentSide,[],R),
    (   last(R,2) ; last(R,3)),
    count_elements(R,2,Twos),
    count_elements(R,3,Threes),
    A is 3 * Threes,
    B is 2 * Twos,
    C is A + B,
    NewScore is Score + C.

get_score(_,_,Score,NewScore) :-
    NewScore = Score.

%Flips the board so that the other player can take their turn
flip_board(Board,Result) :-
    slice(Board,6,11,Front),
    slice(Board,0,5,Back),
    append(Front,Back,Result).

% player vs. cpu game of ouri
play_game(_,CPUScore,_,_) :-
    CPUScore >= 25,
    once(write("CPU Wins!")).

play_game(_,PlayerScore,_,_) :-
    PlayerScore >= 25,
    once(write("Player wins!")).

%Game where the program goes first
play_game(PlayerScore,CPUScore,CurrentBoard,p) :-
    display_board(PlayerScore,CPUScore,CurrentBoard),nl,
    write("CPU Turn: "),nl,
    sleep(2),
    flip_board(CurrentBoard,FlippedBoard),
    best_move_1(FlippedBoard,Move),
    write("CPU Chose Pit "),
    write(Move),nl,nl,
    possible_turn(Move-1,FlippedBoard,UpdatedBoard),
    get_score(FlippedBoard,UpdatedBoard,CPUScore,NewCPUScore),
    clear_pits(FlippedBoard,UpdatedBoard,NextBoard),
    flip_board(NextBoard,NewFlippedBoard),nl,
    write("Player's Turn: "),nl,
    display_board(PlayerScore,NewCPUScore,NewFlippedBoard),nl,
    write("Enter a Pit: "),
    read(Pit),nl,
    possible_turn(Pit-1,NewFlippedBoard,NewUpdatedBoard),
    get_score(NewFlippedBoard,NewUpdatedBoard,PlayerScore,NewPlayerScore),
    clear_pits(NewFlippedBoard,NewUpdatedBoard,FinalBoard),
    play_game(NewPlayerScore,NewCPUScore,FinalBoard,p).

%Game where the program goes second
play_game(PlayerScore,CPUScore,CurrentBoard,s) :-
    display_board(PlayerScore,CPUScore,CurrentBoard),nl,
    write("Enter a Pit: "),
    read(Pit),nl,
    possible_turn(Pit-1,CurrentBoard,NewBoard),
    get_score(CurrentBoard,NewBoard,PlayerScore,NewPlayerScore),
    clear_pits(CurrentBoard,NewBoard,UpdatedBoard),
    display_board(NewPlayerScore,CPUScore,UpdatedBoard),nl,
    write("CPU Turn: "),nl,
    sleep(2),
    flip_board(UpdatedBoard,FlippedBoard),
    best_move_1(FlippedBoard,Move),
    possible_turn(Move-1,FlippedBoard,NewUpdatedBoard),
    get_score(FlippedBoard,NewUpdatedBoard,CPUScore,NewCPUScore),
    clear_pits(FlippedBoard,NewUpdatedBoard,NextBoard),
    flip_board(NextBoard,FinalBoard),nl,
    write("CPU Chose Pit "),
    write(Move),nl,nl,
    play_game(NewPlayerScore,NewCPUScore,FinalBoard,s).




% This is the main predicate used to start a game where the program
% moves first
start_game(-p) :-
    nl,
    write("Welcome to Ouri! The CPU Goes First."),nl,nl,
    play_game(0,0,[4,4,4,4,4,4,4,4,4,4,4,4],p).

%Used to start a game where the player moves first
start_game(-s) :-
    nl,
    write("Welcome to Ouri! The Player Goes First."),nl,nl,
    play_game(0,0,[4,4,4,4,4,4,4,4,4,4,4,4],s).



%||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

%2nd Algorithm
%
% This algorithm determines which pits it can take from and selects one
% at random.

%Determines which pits have seeds (not zero)
get_valid_moves(Board,L):-
    slice(Board,0,5,Player),
    delete(Player,0,L).

%Selects a random pit with seeds in it
best_move_2(Board,M) :-
    get_valid_moves(Board,L),
    random_member(Seeds,L),
    slice(Board,0,5,Player),
    nth1(M,Player,Seeds).



%||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
%
%6 Game tournament between algorithm 1 and algorithm 2
%p = CPU 1 goes first
%s = CPU 2 goes first

% In a situation where the game becomes an infinite loop and the cpus
% are tied, the result of the game is 0 (tie)
play_cpu_game(CPU1Score,CPU2Score,Board,_,Result):-
    sum_list(Board,S),
    S =< 4,
    CPU1Score =:= CPU2Score,
    append([],0,Result).

% In a situation where the game becomes an infinite loop and the cpu2
% has a higher score, the result of the game is 2 (CPU2 wins)
play_cpu_game(CPU1Score,CPU2Score,Board,_,Result):-
    sum_list(Board,S),
    S =< 4,
    CPU2Score > CPU1Score,
    append([],2,Result).

% In a situation where the game becomes an infinite loop and the cpu1
% has a higher score, the result of the game is 1 (CPU1 wins)
play_cpu_game(CPU1Score,CPU2Score,Board,_,Result):-
    sum_list(Board,S),
    S =< 3,
    CPU1Score > CPU2Score,
    append([],1,Result).

%If CPU1 gets to 25 first, 1 is the result
play_cpu_game(CPU1Score,_,_,_,Result) :-
    CPU1Score >= 25,
    append([],1,Result).

%If CPU2 gets to 25 first, 2 is the result
play_cpu_game(_,CPU2Score,_,_,Result) :-
    CPU2Score >= 25,
    append([],2,Result).

%CPU vs CPU game where CPU1 moves first
play_cpu_game(CPU1Score,CPU2Score,CurrentBoard,p,R) :-
    best_move_1(CurrentBoard,Move),
    possible_turn(Move-1,CurrentBoard,UpdatedBoard),
    get_score(CurrentBoard,UpdatedBoard,CPU1Score,NewCPU1Score),
    clear_pits(CurrentBoard,UpdatedBoard,NextBoard),
    flip_board(NextBoard,FlippedBoard),
    best_move_2(FlippedBoard,Move2),
    possible_turn(Move2-1,FlippedBoard,NewUpdatedBoard),
    get_score(FlippedBoard,NewUpdatedBoard,CPU2Score,NewCPU2Score),
    clear_pits(FlippedBoard,NewUpdatedBoard,SemiFinalBoard),
    flip_board(SemiFinalBoard,FinalBoard),
    play_cpu_game(NewCPU1Score,NewCPU2Score,FinalBoard,p,R).

%CPU vs CPU game where CPU2 moves first
play_cpu_game(CPU1Score,CPU2Score,CurrentBoard,s,R) :-
    flip_board(CurrentBoard,FlippedBoard),
    best_move_2(FlippedBoard,Move2),
    possible_turn(Move2-1,FlippedBoard,UpdatedBoard),
    get_score(FlippedBoard,UpdatedBoard,CPU2Score,NewCPU2Score),
    clear_pits(FlippedBoard,UpdatedBoard,NextBoard),
    flip_board(NextBoard,NewFlippedBoard),
    best_move_1(NewFlippedBoard,Move),
    possible_turn(Move-1,NewFlippedBoard,NewUpdatedBoard),
    get_score(NewFlippedBoard,NewUpdatedBoard,CPU1Score,NewCPU1Score),
    clear_pits(NewFlippedBoard,NewUpdatedBoard,FinalBoard),
    play_cpu_game(NewCPU1Score,NewCPU2Score,FinalBoard,s,R).



%Starts the CPU vs CPU game where CPU1 moves first
start_cpu_game(-p,Result) :-
    once(play_cpu_game(0,0,[4,4,4,4,4,4,4,4,4,4,4,4],p,Result)).

%Starts the CPU vs CPU game where CPU2 moves first
start_cpu_game(-s,Result) :-
    once(play_cpu_game(0,0,[4,4,4,4,4,4,4,4,4,4,4,4],s,Result)).


% Starts a 6 game CPU vs CPU Ouri tournament with both CPUs alternating
% with respect to who moves first. Results are displayed at the end in a
% list where index 0 is the first game, index 1 is the second game, etc.
start_cpu_tournament :-
    start_cpu_game(-p,Game1),
    start_cpu_game(-s,Game2),
    start_cpu_game(-p,Game3),
    start_cpu_game(-s,Game4),
    start_cpu_game(-p,Game5),
    start_cpu_game(-s,Game6),
    write("Results"),nl,
    write([Game1,Game2,Game3,Game4,Game5,Game6]).





















