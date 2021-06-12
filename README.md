# Command-Line Chess
The classic game of chess written on the command line using Ruby

## Done
- Basic piece movement
- Pieces have `possible_moves` method which calculate all possible moves
- Board interface (from `chess.rb` which is the first iteration of the project)

## In Progress
- In `possible_moves`, I have to figure out how to store the piece to be moved, and the destination, and whether it's a take (maybe using the `PossibleMove` class)

## To-Do
- `GameController` class which has a `Board`, 2 `Player`s, and a driver method that continues the game until one of the `Player`s are in checkmate
  - `play_game` gets 
    - current player
    - their possible moves
    - listens for the player's choice
    - and then validates the move
- Somewhere, I need to add `get_possible_moves` method that finds all moves a player can make
  - It will first check if the given player is in check
    - If so, then iterate through all the player's possible moves, and see if it would block/take the piece that is delivering check, and add it to the new list of legal, possible moves
    - Return the new list of possible moves
    - Don't forget to undo the move
    - Otherwise, pass the full set of possible moves to `GameController`, and make sure the current player makes one of the moves in the list
- Create a `chess2_spec.rb` so that it supports the new structure created