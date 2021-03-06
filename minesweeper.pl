% Main function to start the program.
main :-
    write("MINESWEEPER"), nl,
    choose_board(Rows, Columns, Mines),
    init_game(Rows, Columns, Mines).


% Main function to run the testing version of the program (for debuging). 
test :-
    write("MINESWEEPER - DEBUGING GAME"), nl,
    choose_board(Rows, Columns, Mines),
    init_test_game(Rows, Columns, Mines).


% choose_board(+Rows, +Columns, +Mines) :- User selects the board size.
choose_board(Rows, Columns, Mines) :-
    write("Choose board size:"), nl,
    write("1. - Beginner (8x8)"), nl,
    write("2. - Intermediate (16x16)"), nl,
    write("3. - Expert (32x32)"), nl,
    write("Your choice: "), read(Choice),

    correct_game(Choice, Rows, Columns, Mines).



% init_game(+Rows, +Columns, +Mines) :- Initialises the gameboard and 
% the revealed board and starts the game loop.
init_game(Rows, Columns, Mines) :-
    generate_game_board(Rows, Columns, Mines, Board),
    generate_empty_board(Rows, Columns, Revealed),
    print_game_board(Rows,Columns, Mines, Revealed),
    NumToReveal is Rows * Columns - Mines,
    start_game(Rows, Columns, Mines, NumToReveal, Board, Revealed).


% Same as init just runs testing game (reveals gameboard for debuging)
init_test_game(Rows, Columns, Mines) :-
    generate_game_board(Rows, Columns, Mines, Board),
    generate_empty_board(Rows, Columns, Revealed),
    print_game_board(Rows,Columns, Mines, Revealed),
    NumToReveal is Rows * Columns - Mines,
    start_test_game(Rows, Columns, Mines, NumToReveal, Board, Revealed).



% --------------------------------------PRINTING FUNCTIONS-----------------------

% print_game_board(+Nrow, +Ncol, +Mines, +Board) :- prints the gameboard with game info.
print_game_board(Nrow, Ncol, Mines, Board) :-
    write("Number of mines is: "), write(Mines), nl,
    nl,
    print_field(Nrow, Ncol, Board).


% print_field(+Nrow, +Ncol, +Board) :- prints the gameboard.
print_field(Nrow, Ncol, Board) :- 
    print_field(Nrow, Ncol, -1, Board).


% print_field(+Nrow, +Ncol, +RowCounter, +Board) :- helper for print_game_board/4 
%       - `RowCounter` - for printing row number and separating header 
%                        (-1 - number of column, 0 - header separator)

% Board already printed.
print_field(_, _, _, []).


% Print header (number of each column)
print_field(Nrow, Ncol, -1, Revealed) :-
    !,
    % creation of the header
    numlist(1, Ncol, ColList),
    % skip first column (num of row)
    write("   |"),
    % print number of each column
    print_row(ColList), nl,

    print_field(Nrow, Ncol, 0, Revealed).


% Print header separator (just line of '-').
print_field(Nrow, Ncol, 0, Revealed) :-
    !, 
    % creation of the separator.
    Nsep is (Ncol + 1) * 3,
    generate_list("-", Nsep, Result),
    atomic_list_concat(Result, '', ToPrint),
    write(ToPrint), nl,

    print_field(Nrow, Ncol, 1, Revealed).


% Print one row of the gameboard.
print_field(Nrow, Ncol, CurRow, [Row|Rest]) :-
    print_number(CurRow), write("|"),
    print_row(Row), nl,
    NewCurRow is CurRow + 1,
    print_field(Nrow, Ncol, NewCurRow, Rest).



% print_row(+Row) :- Prints the content of the list representing one row of the border.
print_row([]).

% Prints mine.
print_row([x|Xs]) :-
    !, 
    write(" x "),
    print_row(Xs).

% Prints unrevealed cell.
print_row([.|Xs]) :-
    !, 
    write(" . "),
    print_row(Xs).

% Prints numbered cell. 
print_row([X|Xs]) :-
    print_number(X),
    print_row(Xs).



% print_number(+Num) :- prints number in the board (to have even spacing).

% Numbers < 10
print_number(Num) :- 
    Num < 10, 
    !,
    write(" "), write(Num), write(" ").

% Numbers >= 10
print_number(Num) :-
    write(Num), write(" ").

% -------------------------------END - PRINTING FUNCTIONS---------------------------


% ------------------------------USEFUL RANDOM AND MATRIX FUNCTIONS------------------------

% random_subset(+List, +M, -RandomSubset) :- randomly selects `M` elements from the `List`.
random_subset(_, 0, []).
random_subset(IndexList, M, [X|Xs]) :-
    length(IndexList, N), 
    N >= M, 
    N > 0,
    random(0, N, RandIndex),
    nth0(RandIndex, IndexList, X),
    select(X, IndexList, NewIndexList),
    M1 is M - 1,
    random_subset(NewIndexList, M1, Xs).



% generate_matrix(+Rows, +Columns, +Content, -Result) :- generates 2D matrix filled with `Content`
generate_matrix(Rows, Columns, Content, Result) :-
	generate_list(Content, Columns, Res1),
	generate_list(Res1, Rows, Result).


% generate_list(+Content, +Length, -List) :- generates list of size `Length` and filled with `Content`
generate_list(_, 0, []).

generate_list(X, N, [X|R]) :- 
    N > 0,
    Next is N-1,
    generate_list(X, Next, R).


% replace_in_matrix(+Prev, +Index, +Element, +Columns, -NewMatrix) :- replaces element
% in matrix on given index (counting from 0, row-wise) with the `Element`
replace_in_matrix(Prev, Index, Elem, Columns, New) :- 
    Index >= 0,
    replace_in_matrix(Prev, Index, Elem, Columns, [], New).

% Replace in current row.
replace_in_matrix([Row|RestRows], Index, Elem, Columns, A, New) :-
    Columns > Index,
    !,
    replace(Row, Index, Elem, NewRow),
    reverse(A, NewA),
    append(NewA, [NewRow|RestRows], New).

% Replace in some of the following rows.
replace_in_matrix([Row|RestRows], Index, Elem, Columns, A, New) :-
    Columns =< Index,
    NewIndex is Index - Columns,
    replace_in_matrix(RestRows, NewIndex, Elem, Columns, [Row|A], New).


% replace(+List, +Index, +Value, -NewList) :- replaces content of the `List` on `Index` with `Value`.
replace([_|T], 0, X, [X|T]) :- !.

replace([H|T], I, X, [H|R]):- 
    I > -1,
    NI is I-1,
    replace(T, NI, X, R), 
    !.

replace(L, _, _, L).


% count(+List, +SymbolToCount, -Num) :- counts number of occurences of `SymbolToCount` in `List`.
count([],_,0).

count([X|T], X, Y):- 
    count(T, X, Z),
    Y is 1 + Z.

count([X1|T], X, Z):- 
    X1 \= X,
    count(T, X, Z).


% convert_coord_index(+Row, +Column, +Ncol, -Index) :- converts coordinates in format (Row, Column), 
% counting from 1, to appropriate `Index` (counting from 0 row-wise).
convert_coord_index(Row, Column, Ncol, Index) :-
    Index is (Row -1) * Ncol + Column - 1.


% convert_index_coord(+Index, +Ncol, -Row, -Column) :- inverse operation of the `convert_coord_index/4`
convert_index_coord(Index, Ncol, Row, Column) :-
    Row is Index div Ncol + 1,
    Column is Index mod Ncol + 1.


% get_value_matrix(+Matrix, +Index, +Ncol, -Result) :- gets value from the matrix based on the index 
% (format of the index from `convert_coord_index/4`).
get_value_matrix([Row|_], Index, Ncol, Result) :-
    Ncol > Index, 
    !,
    nth0(Index, Row, Result).

get_value_matrix([_|RestRows], Index, Ncol, Result) :-
    NewIndex is Index - Ncol,
    get_value_matrix(RestRows, NewIndex, Ncol, Result).



% ------------------------------END - USEFUL RANDOM AND MATRIX FUNCTIONS------------------------


% -----------------------------------------GAME INITIALIZATION----------------------------------

% correct_game(+Choice, -Rows, -Columns, -Mines) :- Checks whether game choice was correct.
% If so, generate gameboard with pre-set number of rows, collumns and mines.

% Correct input:
correct_game(1, 8, 8, 8) :- !.
correct_game(2, 16, 16, 32) :- !.
correct_game(3, 32, 32, 90) :- !.

% Bad input:
correct_game(_, Rows, Columns, Mines) :-
    write("Bad input. Choose again."), nl, nl,
    choose_board(Rows, Columns, Mines).


% generate_game_board(+Rows, +Columns, +Mines, -Board) :- randomly generates valid gameboard.
generate_game_board(Rows, Columns, Mines, Board) :-
    NumCells is Rows * Columns,
    numlist(1, NumCells, IndexList),
    random_subset(IndexList, Mines, MinesSet),
    generate_empty_board(Rows, Columns, EmptyBoard),
    set_mines(EmptyBoard, MinesSet, Columns, MinesBoard),
    count_adjacent(Columns, Rows, MinesBoard, Board).


% generate_empty_board(+Rows, +Columns, -EmptyBoard) :- generates game board filled with empty cells
generate_empty_board(Rows, Columns, EmptyBoard) :-
    generate_matrix(Rows, Columns, ., EmptyBoard).


% set_mines(+EmptyBoard, +MinesSet, +Columns, -MinesBoard) :- places mines from `MinesSet`
% to corresponding position
set_mines(Act, [], _, Act).

set_mines(Act, [X|Xs], Columns, New) :- 
    set_one_mine(Act, X, Columns, New1),
    !,
    set_mines(New1, Xs, Columns, New).


% set_one_mine(+EmptyBoard, +Mine, +Columns, -MinesBoard) :- sets one mine on the gameboard
set_one_mine(Prev, X, Columns, Act) :- 
    Index is X - 1,
    replace_in_matrix(Prev, Index, x, Columns, Act).


% count_adjacent(+Rows, +Columns, +MinesBoard, -Board) :- counts number of 
% neighbouring mines of each cell 
count_adjacent(Rows, Columns, MinesBoard, Board) :- 
    count_adjacent(Rows, Columns, MinesBoard, 0, [], [], Board).

% Counts last row (missing bottom row to check).
count_adjacent(_, _, [Row], _, LastRow, A, Board) :-
    !, 
    count_adjacent_row(LastRow, Row, [], 0, NewRow),
    reverse([NewRow|A], Board).


% Counts adjacent mines on each row except the last one.
count_adjacent(Rows, Columns, [Row, NextRow|MinesBoard], RowPos, LastRow, A, Board) :-
    count_adjacent_row(LastRow, Row, NextRow, 0, NewRow),
    NewRowPos is RowPos + 1,
    count_adjacent(Rows, Columns, [NextRow|MinesBoard], NewRowPos,  Row, [NewRow|A], Board).



% count_adjacent_row(+Prev, +Actual, +Next, +RowNum, -NewRow) :- counts number of neighboring
% mines in each Cell of the given row `Actual`

% We assume that there are at least 3 rows and 3 columns (smallest gamegound in default level is 8x8).

% Last column and mine there.
count_adjacent_row(_, [_, x], _, _, [x]) :- !.

% Last column in the first row.
count_adjacent_row([], [Y1, _], [Z1, Z2], _, [Value]) :-
    !, 
    count_cell_mines([Y1, Z1, Z2], Value).

% Last column in the last row.
count_adjacent_row([X1, X2], [Y1, _], [], _, [Value]) :-
    !, 
    count_cell_mines([X1, X2, Y1], Value).

% Last column in the middle row.
count_adjacent_row([X1, X2], [Y1, _], [Z1, Z2], _, [Value]) :-
    !, 
    count_cell_mines([X1, X2, Y1, Z1, Z2], Value).



% First column in the first row and mine there.
count_adjacent_row([], [x, Y2|RestY], [Z1, Z2|RestZ], 0, [x|NewRow]) :-
    !, 
    count_adjacent_row([], [x, Y2|RestY], [Z1, Z2|RestZ], 1, NewRow).

% First column in the last row and mine there.
count_adjacent_row([X1, X2|RestX], [x, Y2|RestY], [], 0, [x|NewRow]) :-
    !, 
    count_adjacent_row([X1, X2|RestX], [x, Y2|RestY], [], 1, NewRow).

% First column in the middle row and mine there.
count_adjacent_row([X1, X2|RestX], [x, Y2|RestY], [Z1, Z2|RestZ], 0, [x|NewRow]) :-
    !, 
    count_adjacent_row([X1, X2|RestX], [x, Y2|RestY], [Z1, Z2|RestZ], 1, NewRow).


% First column in the first row.
count_adjacent_row([], [Y1, Y2|RestY], [Z1, Z2|RestZ], 0, [Value|NewRow]) :-
    !, 
    count_cell_mines([Y2, Z1, Z2], Value),
    count_adjacent_row([], [Y1, Y2|RestY], [Z1, Z2|RestZ], 1, NewRow).

% First column in the last row.
count_adjacent_row([X1, X2|RestX], [Y1, Y2|RestY], [], 0, [Value|NewRow]) :-
    !, 
    count_cell_mines([X1, X2, Y2], Value),
    count_adjacent_row([X1, X2|RestX], [Y1, Y2|RestY], [], 1, NewRow).

% First column in the middle row.
count_adjacent_row([X1, X2|RestX], [Y1, Y2|RestY], [Z1, Z2|RestZ], 0, [Value|NewRow]) :-
    !, 
    count_cell_mines([X1, X2, Y2, Z1, Z2], Value),
    count_adjacent_row([X1, X2|RestX], [Y1, Y2|RestY], [Z1, Z2|RestZ], 1, NewRow).



% Middle column in the first row and mine there.
count_adjacent_row([], [_, x, Y3|RestY], [_, Z2, Z3|RestZ], ColPos, [x|NewRow]) :-
    !, 
    NewColPos is ColPos + 1,
    count_adjacent_row([], [x, Y3|RestY], [Z2, Z3|RestZ], NewColPos, NewRow).

% Middle column in the last row and mine there.
count_adjacent_row([_, X2, X3|RestX], [_, x, Y3|RestY], [] , ColPos, [x|NewRow]) :-
    !, 
    NewColPos is ColPos + 1,
    count_adjacent_row([X2, X3|RestX], [x, Y3|RestY], [], NewColPos, NewRow).

% Middle column in the middle row and mine there.
count_adjacent_row([_, X2, X3|RestX], [_, x, Y3|RestY], [_, Z2, Z3|RestZ], ColPos, [x|NewRow]) :-
    !, 
    NewColPos is ColPos + 1,
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


% count_cell_mines(+CellsToCheck, -NumOfMines) :- counts mines in neighborhood (`CellsToCheck`).
count_cell_mines(CellsToCheck, Num) :-
    count(CellsToCheck, x, Num). 


% -----------------------------------------END - GAME INITIALIZATION----------------------------------


% ----------------------------------------------GAME LOGIC---------------------------------------------


% start_game(+Rows, +Columns, +Mines, +Gameboard, -Revealed) :- manages one game loop.
start_game(Nrow, Ncol, Mines, NumToReveal, Gameboard, Revealed) :-
    write("-------------------------------------------"), nl,
    write("Make your next move!"), nl,
    % Actual move logic
    request_row_col(Nrow, Ncol, Revealed, Row, Col),
    reveal_position(Row, Col, Nrow, Ncol, NumToReveal, Gameboard, Revealed, NewNumToReveal, ToReveal, NewRevealed),
    % Checking game situation and next move.
    print_game_board(Nrow, Ncol, Mines, NewRevealed),
    next_move(Nrow, Ncol, Mines, NewNumToReveal, Gameboard, ToReveal, NewRevealed).


% Same as start_game just writes revealed gameboard before first move (for debuging).
start_test_game(Nrow, Ncol, Mines, NumToReveal, Gameboard, Revealed) :-
    write("-------------------------------------------"), nl,
    write("Make your next move!"), nl,
    print_game_board(Nrow, Ncol, Mines, Gameboard),
    % Actual move logic
    request_row_col(Nrow, Ncol, Revealed, Row, Col),
    reveal_position(Row, Col, Nrow, Ncol, NumToReveal, Gameboard, Revealed, NewNumToReveal, ToReveal, NewRevealed),
    % Checking game situation and next move.
    print_game_board(Nrow, Ncol, Mines, NewRevealed),
    next_move(Nrow, Ncol, Mines, NewNumToReveal, Gameboard, ToReveal, NewRevealed).


% request_row_col(+Nrow, +Ncol, +Revealed, -Row, -Col) :- manages one user game move.
request_row_col(Nrow, Ncol, Revealed, Row ,Col) :-
    write("Row    of cell to reveal:  "), read(ReadR),
    write("Column of cell to reveal:  "), read(ReadC),
    check_row_col(Nrow, Ncol, Revealed, ReadR, ReadC, Row, Col).


% check_row_col(+Nrow, +Ncol, +Revealed, +ReadRow, +ReadCol, -Row, -Col) :- checks whether
% the user input was correct, if not requests another input.
check_row_col(Nrow, Ncol, Revealed, Row, Col, Row, Col) :- 
    in_bounds(Nrow, Ncol, Row, Col), 
    convert_coord_index(Row, Col, Ncol, Index),
    % input coordinates are of the unrevealed cell
    get_value_matrix(Revealed, Index, Ncol, .), 
    !.

% Bad input
check_row_col(Nrow, Ncol, Revealed, _, _, Row, Col) :-
    write("Bad input. Please enter again."), nl,
    request_row_col(Nrow, Ncol, Revealed, Row, Col).


% in_bounds(+NRow, +Ncol, +Row, +Col) :- checks whether coordinates are valid and inside of the gameboard.
in_bounds(Nrow,Ncol,Row,Col) :-
    integer(Nrow), integer(Ncol),
    0 < Row, 0 < Col,
    Nrow >= Row, Ncol >= Col.


% reveal_position(+Row, +Col, +Nrow, +Ncol, +NumToReveal, +Gameboard, +Revealed, -NewNumToReveal, -ToReveal, -NewRevealed) :-
% reveals the cell on the coordinates (Row, Col), 
% if there is no mine in the neighborhood reveals also neighboring cells.
% Actualizes number of unrevealed number of non-mine cells `NewNumToReveal`, 
% gets value on the coordinate `ToReveal` and actualizes revealed gameboard `NewRevealed`.

% No neighboring mines, reveal the neighbours too.
reveal_position(Row, Col, Nrow, Ncol, NumToReveal, Gameboard, Revealed, NewNumToReveal, 0, NewRevealed) :-
    convert_coord_index(Row, Col, Ncol, Index),
    get_value_matrix(Gameboard, Index, Ncol, 0), 
    !,
    replace_in_matrix(Revealed, Index, 0, Ncol, NewRevealed1),
    NNTR1 is NumToReveal -1,
    reveal_zero_position(Row, Col, Nrow, Ncol, NNTR1, Gameboard, NewRevealed1, NewNumToReveal, NewRevealed).

% Either mine or a neighbour of the mine.
reveal_position(Row, Col, _, Ncol, NumToReveal, Gameboard, Revealed, NewNumToReveal, ToReveal, NewRevealed) :-
    convert_coord_index(Row, Col, Ncol, Index),
    get_value_matrix(Gameboard, Index, Ncol, ToReveal),
    replace_in_matrix(Revealed, Index, ToReveal, Ncol, NewRevealed),
    NewNumToReveal is NumToReveal - 1.


% reveal_zero_position(+Row, +Col, +Nrow, +Ncol, +NumToReveal, +Gameboard, +Revealed, -NewNumToReveal, -NewRevealed) :-
% reveals neighbourhood of the cell with no mine neighbour
reveal_zero_position(Row, Col, Nrow, Ncol, NumToReveal, Gameboard, Revealed, NewNumToReveal, NewRevealed) :-
    % Help variables - to check all the neighbours
    RowL is Row - 1,
    RowR is Row + 1,
    ColL is Col - 1,
    ColR is Col + 1,

    % Checking each neighbour
    reveal_auto(RowL, ColL, Nrow, Ncol, NumToReveal, Gameboard, Revealed, NNTR1, NR1),
    reveal_auto(RowL, Col, Nrow, Ncol, NNTR1, Gameboard, NR1, NNTR2, NR2),
    reveal_auto(RowL, ColR, Nrow, Ncol, NNTR2, Gameboard, NR2, NNTR3, NR3),
    reveal_auto(Row, ColL, Nrow, Ncol, NNTR3, Gameboard, NR3, NNTR4, NR4),
    reveal_auto(Row, ColR, Nrow, Ncol ,NNTR4, Gameboard, NR4, NNTR5, NR5),
    reveal_auto(RowR, ColL, Nrow, Ncol, NNTR5, Gameboard, NR5, NNTR6, NR6),
    reveal_auto(RowR, Col, Nrow, Ncol, NNTR6, Gameboard, NR6, NNTR7, NR7),
    reveal_auto(RowR, ColR, Nrow, Ncol, NNTR7, Gameboard, NR7, NewNumToReveal, NewRevealed).


% reveal_auto(+Row, +Col, +Nrow, +Ncol, +NumToReveal, +Gameboard, +Revealed, -NewNumToReveal, -NewRevealed) :-
% reveals cell during revealing cell with no mine neighbour

% New index to reveal is not already reveled and it is a valid coordinate
reveal_auto(Row, Col, Nrow, Ncol, NumToReveal, Gameboard, Revealed, NewNumToReveal, NewRevealed) :-
    in_bounds(Nrow, Ncol, Row, Col),
    convert_coord_index(Row, Col, Ncol, Index),
    get_value_matrix(Revealed, Index, Ncol, .), 
    !,
    reveal_position(Row, Col, Nrow, Ncol, NumToReveal, Gameboard, Revealed, NewNumToReveal, _, NewRevealed).

% Given position is already revealed or not valid.
reveal_auto(_, _, _, _, NumToReveal, _, Revealed, NumToReveal, Revealed).


% next_move(+Nrow, +Ncol, +Mines, +NumToReveal, +Gameboard, +ToReveal, +NewRevealed) :-
% checks actual game situation and does proper action.

% Mine reveal -> GAME OVER
next_move(Nrow, Ncol, _, _, Gameboard, x, _) :-
    write("You have revealed a mine!"), nl,
    write("Game over!"), nl,
    print_field(Nrow, Ncol, Gameboard).

% All cell revealed -> WIN
next_move(Nrow, Ncol, _, 0, Gameboard, _, _) :-
    write("You won!"), nl,
    print_field(Nrow, Ncol, Gameboard).

% Valid move -> Do next move
next_move(Nrow, Ncol, Mines, NumToReveal, Gameboard, _, Revealed) :-
    start_game(Nrow, Ncol, Mines, NumToReveal, Gameboard, Revealed).


% ----------------------------------------------END - GAME LOGIC---------------------------------------------