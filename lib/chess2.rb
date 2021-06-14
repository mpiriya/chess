class GameConroller
  def initialize
    @board = Board.new
    @white = Player.new(@board, "white")
    @black = Player.new(@board, "black")
    @white.other_player = @black
    @black.other_player = @white
    @current = @white
  end

  def play_game
    puts "Welcome to Chess!\nTake turns with a friend entering moves using the format [rank][file] [rank][file]"
    puts "\twhere the first coordinate is that of the piece you wish to move"
    puts "\tand the second is the destination you wish to move that piece to"
    puts "Rank: A-H, where A is white's first row, and H is black's first row"
    puts "File: 1-8, where 1 is the bottom-left corner from white's perspective,\n\tand 8 is the bottom-left corner from black's perspective"

    while !@current.in_checkmate
      puts "Please enter your move (" + (@isWhite ? "white" : "black") + " to move): \n"
      input = gets.chomp

      processed_input = process_input(input)

      if processed_input == nil
        puts "Please use format [rank][file] [rank][file]"
        next
      end

      turn_valid = process_turn(processed_input[0], processed_input[1], processed_input[2], processed_input[3])
      if turn_valid
        @current = @current.otherPlayer
      end
    end
  end

  def process_input(input)
    # rank is the col, and file is the row, so be careful
    arr = input.split
    if arr.length != 2
      return nil
    end
    from = arr[0].upcase
    to = arr[1].upcase

    from_rf = from.split("")
    to_rf = to.split("")

    # are the letters valid and the first part of each coordinate
    if "ABCDEFGH".index(from_rf[0]) == nil || "ABCDEFGH".index(to_rf[0])
      return nil
    end
    
    from_file = from_rf[1].to_i
    to_file = to_rf[1].to_i

    if from_file < 1 || from_file > 8 || to_file < 1 || to_file > 8
      return nil
    end

    return 8 - from_file, "ABCDEFGH".index(from_rf[0]), 8 - to_file, "ABCDEFGH".index(to_rf[0])
  end

  # input
  def process_turn(from_row, from_col, to_row, to_col)
    legal_moves = @current.all_legal_moves
    # check if current player has a piece at from_row, from_col
    from_piece = @board.piece_at(from_row, from_col)
    if from_piece != nil && from_piece.isWhite == @current.isWhite
      # then checks if one of the legal moves match the desired move
      legal_moves.each do |possible_move|
        if possible_move.from_cell.row == from_row && possible_move.from_cell.col == from_col && possible_move.to_cell.row == to_row && possible_move.to_cell.col == to_col
          # move the piece
          possible_move.from_cell.piece.move(to_row, to_col)
          if possible_move.from_cell.piece.instance_of?(Pawn)
            possible_move.from_cell.piece.has_moved = true
          end

          #check if it puts the other player in checkmate
          if @current.other_player.in_check? && @current.other_player.all_legal_moves.empty?
            @current.other_player.in_checkmate = true
          end
          return true
        else
          # if the move is invalid?
          puts "Error: piece at #{"ABCDEFGH"[from_col]}#{8 - from_row} cannot move to #{"ABCDEFGH"[from_col]}#{8 - from_row}"
          return false
        end
      end
    else
      puts "Error: you do not have a piece at #{"ABCDEFGH"[from_col]}#{8 - from_row}"
      return false
    end
  end
end

class Player
  attr_accessor :other_player, :in_checkmate
  attr_reader :board, :isWhite, :pieces, :king
  
  # takes in Board and Color module (Color::BLACK or Color::WHITE)
  def initialize(board, color)
    @board = board
    @isWhite = color == "white"
    if(@isWhite)
      8.times {|i| @pawns << Pawn.new(board, "white", 6, i)}
      @pieces << Rook.new(board, "white", 7, 0)
      @pieces << Rook.new(board, "white", 7, 7)
      @pieces << Knight.new(board, "white", 7, 1)
      @pieces << Knight.new(board, "white", 7, 6)
      @pieces << Bishop.new(board, "white", 7, 2)
      @pieces << Bishop.new(board, "white", 7, 5)
      @pieces << Queen.new(board, "white", 7, 3)
      @king = King.new(board, "white", 7, 4)
    else #color is black
      8.times {|i| @pawns << Pawn.new(board, "black", 1, i)}
      @pieces << Rook.new(board, "black", 0, 0)
      @pieces << Rook.new(board, "black", 0, 7)
      @pieces << Knight.new(board, "black", 0, 1)
      @pieces << Knight.new(board, "black", 0, 6)
      @pieces << Bishop.new(board, "black", 0, 2)
      @pieces << Bishop.new(board, "black", 0, 5)
      @pieces << Queen.new(board, "black", 0, 3)
      @king = King.new(board, "black", 0, 4)
    end
    @in_checkmate = false
  end

  def all_legal_moves
    to_ret = []

    #gets EVERY POSSIBLE move, even the ones that would put the player in check
    @pieces.each { |piece| to_ret.concat(piece.possible_moves) }
    to_ret.concat(@king.possible_moves)
    
    # test each move, and if it results in the player in check, remove it from the list
    to_remove = []
    @to_ret.each do |possible_move|
      # save the piece's row and col
      prev_row = possible_move.from_cell.row
      prev_col = possible_move.from_cell.col
      curr_piece = possible_moves.from_cell.piece

      # move the piece at from_cell to the new square
      curr_piece.move(possible_move.to_cell.row, possible_move.to_cell.col)

      #is the player in check?
      if in_check?
        # undo the move
        curr_piece.move(prev_row, prev_col)
        # add it to the list of moves to be removed from to_ret
        to_remove << possible_move
      end
    end

    #for each element in to_ret, delete if the element exists in the to_remove array
    to_ret.delete_if {|elem| to_remove.index(elem) != nil}

    return to_ret
  end

  def in_check?
    @otherPlayer.pieces.each do |piece|
      piece.possible_moves.each do |possible_move|
        return true if possible_move.to_cell.piece == @king
      end
    end
    return false
  end
end

class Board 
  attr_accessor :board

  def initialize
    @board = Array.new(8) {|r| Array.new(8) {|c| Cell.new(nil, r, c)}}
  end

  def cell_at(row, col)
    return nil if row < 0 || row > 7 || col < 0 || col > 7
    return @board[row][col]
  end

  def piece_at(row, col)
    return nil if row < 0 || row > 7 || col < 0 || col > 7
    return @board[row][col].piece
  end

  def set_piece(row, col, piece)
    @board[row][col].piece = piece
  end

  def to_s
    to_ret = "-"*31 + "\n "
    @board.each { |elem| to_ret += "#{elem.join(" | ")}\n" + "-"*31 + "\n "}
    to_ret
  end
end

class Cell
  attr_accessor :piece
  attr_reader :row, :col
  def initialize(piece, row, col)
    @piece = piece
    @row = row
    @col = col
  end

  def to_s
    if piece == nil
      return " "
    else
      return piece.to_s
    end
  end
end

class PossibleMove
  attr_reader :from_cell, :to_cell
  def initialize(from_cell, to_cell)
    @from_cell = from_cell
    @to_cell = to_cell
  end

  def to_s
    "Moving from board[#{from_cell.row}][#{from_cell.col}] to board[#{to_cell.row}][#{to_cell.col}]"
  end
end

class Piece
  attr_reader :isWhite
  attr_accessor :row, :col, :available_squares

  def initialize(board, color, row, col)
    @board = board
    @isWhite = color == "white"
    @row = row
    @col = col
  end

  def move(row, col)
    @board.set_piece(@row, @col, nil)
    @row = row
    @col = col
    @board.set_piece(@row, @col, self)
  end

  def self.is_off_board?(row, col)
    return row < 0 || row > 7 || col < 0 || col > 7
  end

  # DOES NOT CHECK WHETHER THE MOVE RESULTS IN CHECK, AND IS THUS INVALID (pin)
  # returns list of PossibleMove's which contain the piece and the cell to move to
  def possible_moves
    return []
  end

  # delta_row and delta_col are either -1, 0, or 1
  # line_of_sight gives all the pieces this piece can see in the "direction" given
  def line_of_sight(delta_row, delta_col)
    to_ret = []
    i = 1
    curr = @board.piece_at(@row + delta_row * i, @col + delta_col * i)
    while curr == nil do
      to_ret << PossibleMove.new(@board.cell_at(@row, @col), curr)
      i += 1
      curr = @board.piece_at(@row + delta_row * i, @col + delta_col * i)
    end
    if curr.isWhite != @isWhite
      to_ret << PossibleMove.new(@board.cell_at(@row, @col), curr)
    end
    return to_ret
  end
end

class Pawn < Piece
  attr_accessor :has_moved
  def initialize(board, color, row, col)
    super(board, color, row, col)
    @has_moved = false
  end
  
  def possible_moves
    to_ret = []
    dir = @isWhite ? -1 : 1
    #the one right in front of it
    curr = @board.cell_at(@row + dir, @col)
    if curr.piece == nil
      to_ret << PossibleMove.new(@board.cell_at(@row, @col), curr) if curr.piece == nil
      # it can only move 2 up if it can move one up
      if !@has_moved
        # the spot 2 in front of it if it hasn't moved yet
        curr = @board.cell_at(@row + 2*dir, @col)
        to_ret << PossibleMove.new(@board.cell_at(@row, @col), curr) if curr.piece == nil
      end
    end
    
    # front-left
    curr = @board.piece_at(@row + dir, @col - 1)
    to_ret << PossibleMove.new(@board.cell_at(@row, @col), curr) if curr != nil && curr.isWhite != @isWhite
    # front-right
    curr = @board.piece_at(@row + dir, @col + 1)
    to_ret << PossibleMove.new(@board.cell_at(@row, @col), curr) if curr != nil && curr.isWhite != @isWhite

    return to_ret
  end

  def to_s 
    @isWhite ? "*" : "*".light_blue
  end
end

class Knight < Piece
  def possible_moves
    # for knights, this will just be 
    to_ret = []

    # up-left
    curr = @board.piece_at(@row - 2, @col - 1)
    to_ret << PossibleMove.new(@board.cell_at(@row, @col), curr) if curr == nil || curr.isWhite != @isWhite
    # up-right
    curr = @board.piece_at(@row - 2, @col + 1)
    to_ret << PossibleMove.new(@board.cell_at(@row, @col), curr) if curr == nil || curr.isWhite != @isWhite
    # down-left
    curr = @board.piece_at(@row + 2, @col - 1)
    to_ret << PossibleMove.new(@board.cell_at(@row, @col), curr) if curr == nil || curr.isWhite != @isWhite
    # down-right
    curr = @board.piece_at(@row + 2, @col + 1)
    to_ret << PossibleMove.new(@board.cell_at(@row, @col), curr) if curr == nil || curr.isWhite != @isWhite
    # left-up
    curr = @board.piece_at(@row - 1, @col - 2)
    to_ret << PossibleMove.new(@board.cell_at(@row, @col), curr) if curr == nil || curr.isWhite != @isWhite
    # left-down
    curr = @board.piece_at(@row + 1, @col - 2)
    to_ret << PossibleMove.new(@board.cell_at(@row, @col), curr) if curr == nil || curr.isWhite != @isWhite
    # right-up
    curr = @board.piece_at(@row - 1, @col + 2)
    to_ret << PossibleMove.new(@board.cell_at(@row, @col), curr) if curr == nil || curr.isWhite != @isWhite
    # right-down
    curr = @board.piece_at(@row + 1, @col + 2)
    to_ret << PossibleMove.new(@board.cell_at(@row, @col), curr) if curr == nil || curr.isWhite != @isWhite

    return to_ret
  end

  def to_s
    @isWhite ? "N" : "N".light_blue
  end
end

class Bishop < Piece
  def possible_moves
    to_ret = []

    # up-left
    to_ret.concat(line_of_sight(-1, -1))
    # up-right
    to_ret.concat(line_of_sight(-1, 1))
    # down-left
    to_ret.concat(line_of_sight(1, -1))
    # down-right
    to_ret.concat(line_of_sight(1, 1))

    return to_ret
  end

  def to_s
    @isWhite ? "B" : "B".light_blue
  end
end

class Rook < Piece
  def possible_moves
    to_ret = []

    # up
    to_ret.concat(line_of_sight(-1, 0))
    # down
    to_ret.concat(line_of_sight(1, 0))
    # left
    to_ret.concat(line_of_sight(0, -1))
    # right
    to_ret.concat(line_of_sight(0, 1))

    return to_ret
  end

  def to_s
    @isWhite ? "R" : "R".light_blue
  end
end

class Queen < Piece
  def possible_moves
    to_ret = []

    # up
    to_ret.concat(line_of_sight(-1, 0))
    # down
    to_ret.concat(line_of_sight(1, 0))
    # left
    to_ret.concat(line_of_sight(0, -1))
    # right
    to_ret.concat(line_of_sight(0, 1))
    # up-left
    to_ret.concat(line_of_sight(-1, -1))
    # up-right
    to_ret.concat(line_of_sight(-1, 1))
    # down-left
    to_ret.concat(line_of_sight(1, -1))
    # down-right
    to_ret.concat(line_of_sight(1, 1))

    return to_ret
  end

  def to_s
    @isWhite ? "Q" : "Q".light_blue
  end
end

class King < Piece
  def possible_moves
    to_ret = []

    for i in -1..1 
      for j in -1..1
        if i != 0 || j != 0
          curr = @board.piece_at(@row + i, @col + j)
          to_ret << curr if curr.isWhite != @isWhite
        end
      end
    end
      
    return to_ret
  end

  def to_s
    @isWhite ? "K" : "K".light_blue
  end
end

b = Board.new
p = Pawn.new(b, "white", 6, 6)
b.set_piece(p.row, p.col, p)
poss = p.possible_moves
puts poss