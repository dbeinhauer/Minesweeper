# Minesweeper
Assignment project for Non-Procedural Programing course.

## Basic Info
The board representation:
```
   | 1  2  3  4  5  6  7  8
---------------------------
 1 | .  .  .  1  0  0  0  0
 2 | .  .  .  2  1  1  1  0
 3 | .  .  .  .  .  .  1  0
 4 | .  .  .  .  2  1  1  0
 5 | .  .  3  1  1  0  0  0
 6 | .  .  2  0  0  0  0  0
 7 | 1  1  1  0  0  0  1  1
 8 | 0  0  0  0  0  0  1  x
```
Where the first column and the first row represents boarders of the gameboard with appropriate coordinates.


### Symbols On The Table
* `.` - unrevealed cell
* `x` - mine
* `0-8` - number symbolizing number of adjacent mines to the cell

## Usage
Install [SWI-Prolog](https://www.swi-prolog.org/). Run the executable (`swipl`) and consult `minesweeper.pl`. From the directory containing `minesweeper.pl`:

```
?- [minesweeper].
```

Then run the query for starting the program:
```
?- main.
```
Or the query for testing the program:
```
?- test.
```

### Game Initialization
After runnig commands above it is necessary to choose the gameboard by running one of the suggested commands (e.g. running command `1.` generates gameboard of the size 8x8):
```
MINESWEEPER
Choose board size:
1. - Beginner (8x8)
2. - Intermediate (16x16)
3. - Expert (32x32)
Your choice:
```

### Game Loop
During each game loop there is printed currently revealed part of the gameboard and you are also asked to 
choose your next move by runnig commands symbolizing specific row or column (e.g. command below reveals 2nd 
row and 3rd column).
```
Make your next move!
Row    of cell to reveal:  |: 2.
Column of cell to reveal:  |: 3.
```
If input is wrong you are asked for the correct with the mesage:
```
Bad input. Please enter again.
```

### End Of The Game
If you reveal a mine, you lose and program ends with the following message.
```
You have revealed a mine!
Game over!
```
If you reveal all non-mine cells, you win and program ends with the following message.
```
You won!
```