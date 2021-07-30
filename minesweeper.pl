% chdir(`C:/Users/David/source/repos/Zapoctovy_program_neprocko/Minesweeper`).
% [minesweeper].

% Main function to start the program.
main :-
    write("MINESWEEPER"), nl,
    choose_board(Rows, Columns, Mines),
    init_game(Rows, Columns, Mines).


% choose_board(+Rows, +Columns, +Mines) :- User selects the play board size
choose_board(Rows, Columns, Mines) :-
    write("Choose board size:"), nl,
    write("1. - Beginner (8x8)"), nl,
    write("2. - Intermediate (16x16)"), nl,
    write("3. - Expert (32x32)"), nl,
    write("Your choice: "), read(Choice),
    correct_game(Choice, Rows, Columns, Mines).


% init_game(+Rows, +Columns, +Mines) :- 
init_game(Rows, Columns, Mines) :-
    generate_game_board(Rows, Columns, Mines, Board),
    start_game(Rows, Columns, Mines, Board, Revealed).


% correct_game(+Choice, -Rows, -Columns, -Mines) :- Checks whether game choice was correct.
% If so, generate pre-set number of rows, collumns and mines.

% Correct input:
correct_game(1, 8, 8, 10) :- !.
correct_game(2, 16, 16, 40) :- !.
correct_game(3, 32, 32, 100) :- !.
% Bad input:
correct_game(_, Rows, Columns, Mines) :-
    write("Bad input. Choose again."), nl, nl,
    choose_board(Rows, Columns, Mines).


% generate_game_board(+Rows, +Columns, +Mines, -Board) :- randomly generates valid gameboard
generate_game_board(Rows, Columns, Mines, Board) :-
    NumCells is Rows*Columns,
    numlist(1, NumCells, IndexList),
    random_subset(IndexList, Mines, MinesSet),
    generate_empty_board(Rows, Columns, EmptyBoard),
    set_mines(EmptyBoard, MinesSet, Columns, MinesBoard),
    count_adjacent(Columns, Rows, MinesBoard, Board).
    % Board = MinesBoard.


% random_subset(+List, +M, -RandomSubset) :- randomly selects `M` elements from the `List`.
random_subset(_, 0, []) :- !.
random_subset(IndexList, M, [X|Xs]) :-
    length(IndexList, N), 
    N >= M,
    random(0, N, RandIndex),
    nth0(RandIndex, IndexList, X),
    select(X, IndexList, NewIndexList),
    M1 is M - 1,
    random_subset(NewIndexList, M1, Xs).

% generate_empty_board(+Rows, +Columns, -EmptyBoard) :- generates game board filled with empty cells
generate_empty_board(Rows, Columns, EmptyBoard) :-
    generate_matrix(Rows, Columns, 0, EmptyBoard).


% generate_matrix(+Rows, +Columns, +Content, -Result) :- generates 2D matrix filled with `Content`
generate_matrix(Rows, Columns, Content, Result) :-
	generate_list(Content, Columns, Res1),
	generate_list(Res1, Rows, Result).


% generate_list(+Content, +Length, -List) :- generates list of size `Length` and filled with `Content`
generate_list(_, 0, []).
generate_list(X, N, [X|R]) :- N>0, Next is N-1, generate_list(X, Next, R).


% set_mines(+EmptyBoard, +MinesSet, +Columns, -MinesBoard) :- places mines from `MinesSet` to corresponding position
set_mines(Act, [], _, Act).
set_mines(Act, [X|Xs], Columns, New) :- 
    set_one_mine(Act, X, Columns, New1), !,
    set_mines(New1, Xs, Columns, New).


% set_one_mine(+EmptyBoard, +Mine, +Columns, -MinesBoard) :- sets one mine on the gameboard
set_one_mine(Prev, X, Columns, Act) :- 
    Index is X - 1,
    replace_in_matrix(Prev, Index, Columns, Act).


replace_in_matrix(Prev, Index, Columns, New) :- replace_in_matrix(Prev, Index, Columns, [], New).
replace_in_matrix([Row|RestRows], Index, Columns, A, New) :-
    Columns > Index,
    replace(Row, Index, x, NewRow),
    reverse(A, NewA),
    append(NewA, [NewRow|RestRows], New).

replace_in_matrix([Row|RestRows], Index, Columns, A, New) :-
    Columns =< Index,
    NewIndex is Index - Columns,
    replace_in_matrix(RestRows, NewIndex, Columns, [Row|A], New).


replace([_|T], 0, X, [X|T]).
replace([H|T], I, X, [H|R]):- I > -1, NI is I-1, replace(T, NI, X, R), !.
replace(L, _, _, L).


% count_adjacent(+NumCells, +Rows, +Columns, +MinesBoard, -Board).
count_adjacent(Rows, Columns, MinesBoard, Board) :- 
    count_adjacent(Rows, Columns, MinesBoard, 0, [], [], Board).

% count_adjacent(_, Rows, _, _, _, RowPos, A, Board) :-
%     RowPos =< Rows, !,
%     reverse(A, Board).

count_adjacent(Rows, Columns, [Row], RowPos, LastRow, A, Board) :-
    !, count_adjacent_row(LastRow, Row, [], 0, NewRow),
    reverse([NewRow|A], Board).


count_adjacent(Rows, Columns, [Row, NextRow|MinesBoard], RowPos, LastRow, A, Board) :-
    count_adjacent_row(LastRow, Row, NextRow, 0, NewRow),
    NewRowPos is RowPos + 1,
    count_adjacent(Rows, Columns, [NextRow|MinesBoard], NewRowPos,  Row, [NewRow|A], Board).



% count_adjacent_row(_, [], _, _, []).
% count_adjacent_row(_, [_], _, _, []) :- !.

% We assume that there are at least 3 rows and 3 columns.

% Last column and mine there.
count_adjacent_row(_, [_, x], _, _, [x]) :- !.

% Last column in the first row.
count_adjacent_row([], [Y1, _], [Z1, Z2], _, [Value]) :-
    !, count_cell_mines([Y1, Z1, Z2], Value).

% Last column in the last row.
count_adjacent_row([X1, X2], [Y1, _], [], _, [Value]) :-
    !, count_cell_mines([X1, X2, Y1], Value).

% Last column in the middle row.
count_adjacent_row([X1, X2], [Y1, _], [Z1, Z2], _, [Value]) :-
    !, count_cell_mines([X1, X2, Y1, Z1, Z2], Value).


% First column in the first row and mine there.
count_adjacent_row([], [x, Y2|RestY], [Z1, Z2|RestZ], 0, [x|NewRow]) :-
    !, count_adjacent_row([], [x, Y2|RestY], [Z1, Z2|RestZ], 1, NewRow).

% First column in the last row and mine there.
count_adjacent_row([X1, X2|RestX], [x, Y2|RestY], [], 0, [x|NewRow]) :-
    !, count_adjacent_row([X1, X2|RestX], [x, Y2|RestY], [], 1, NewRow).

% First column in the middle row and mine there.
count_adjacent_row([X1, X2|RestX], [x, Y2|RestY], [Z1, Z2|RestZ], 0, [x|NewRow]) :-
    !, count_adjacent_row([X1, X2|RestX], [x, Y2|RestY], [Z1, Z2|RestZ], 1, NewRow).


% First column in the first row.
count_adjacent_row([], [Y1, Y2|RestY], [Z1, Z2|RestZ], 0, [Value|NewRow]) :-
    !, count_cell_mines([Y2, Z1, Z2], Value),
    count_adjacent_row([], [Y1, Y2|RestY], [Z1, Z2|RestZ], 1, NewRow).

% First column in the last row.
count_adjacent_row([X1, X2|RestX], [Y1, Y2|RestY], [], 0, [Value|NewRow]) :-
    !, count_cell_mines([X1, X2, Y2], Value),
    count_adjacent_row([X1, X2|RestX], [Y1, Y2|RestY], [], 1, NewRow).

% First column in the middle row.
count_adjacent_row([X1, X2|RestX], [Y1, Y2|RestY], [Z1, Z2|RestZ], 0, [Value|NewRow]) :-
    !, count_cell_mines([X1, X2, Y2, Z1, Z2], Value),
    count_adjacent_row([X1, X2|RestX], [Y1, Y2|RestY], [Z1, Z2|RestZ], 1, NewRow).


% Middle column in the first row and mine there.
count_adjacent_row([], [_, x, Y3|RestY], [_, Z2, Z3|RestZ], ColPos, [x|NewRow]) :-
    !, NewColPos is ColPos + 1,
    count_adjacent_row([], [x, Y3|RestY], [Z2, Z3|RestZ], NewColPos, NewRow).

% Middle column in the last row and mine there.
count_adjacent_row([_, X2, X3|RestX], [_, x, Y3|RestY], [] , ColPos, [x|NewRow]) :-
    !, NewColPos is ColPos + 1,
    count_adjacent_row([X2, X3|RestX], [x, Y3|RestY], [], NewColPos, NewRow).

% Middle column in the middle row and mine there.
count_adjacent_row([_, X2, X3|RestX], [_, x, Y3|RestY], [_, Z2, Z3|RestZ], ColPos, [x|NewRow]) :-
    !, NewColPos is ColPos + 1,
    count_adjacent_row([X2, X3|RestX], [x, Y3|RestY], [Z2, Z3|RestZ], NewColPos, NewRow).


% Middle column in the first row and mine there.
count_adjacent_row([], [Y1, Y2, Y3|RestY], [Z1, Z2, Z3|RestZ], ColPos, [Value|NewRow]) :-
    count_cell_mines([Y1, Y3, Z1, Z2, Z3], Value),
    NewColPos is ColPos + 1,
    count_adjacent_row([], [Y2, Y3|RestY], [Z2, Z3|RestZ], NewColPos, NewRow).

% Middle column in the last row and mine there.
count_adjacent_row([X1, X2, X3|RestX], [Y1, Y2, Y3|RestY], [] , ColPos, [Value|NewRow]) :-
    count_cell_mines([X1, X2, X3, Y1, Y3], Value),
    NewColPos is ColPos + 1,
    count_adjacent_row([X2, X3|RestX], [Y2, Y3|RestY], [], NewColPos, NewRow).

% Middle column in the middle row and mine there.
count_adjacent_row([X1, X2, X3|RestX], [Y1, Y2, Y3|RestY], [Z1, Z2, Z3|RestZ], ColPos, [Value|NewRow]) :-
    count_cell_mines([X1, X2, X3, Y1, Y3, Z1, Z2, Z3], Value),
    NewColPos is ColPos + 1,
    count_adjacent_row([X2, X3|RestX], [Y2, Y3|RestY], [Z2, Z3|RestZ], NewColPos, NewRow).





get_in_matrix([Row|_], Index, Columns, Result) :-
    Columns > Index, !,
    nth0(Index, Row, Result).

get_in_matrix([_|RestRows], Index, Columns, Result) :-
    NewIndex is Index - Columns,
    get_in_matrix(RestRows, NewIndex, Columns, Result).


count_cell_mines(CellsToCheck, Num) :-
    count(CellsToCheck, x, Num). 


count([],_,0).
count([X|T],X,Y):- count(T,X,Z), Y is 1+Z.
count([X1|T],X,Z):- X1\=X,count(T,X,Z).












% X = [[0, x, 0], [x, 0, 0], [x, x, x]], count_adjacent(3, 3, X, Y).
% count_adjacent_row([], [0, x, 0], [x, 0, 0], 0,  X).