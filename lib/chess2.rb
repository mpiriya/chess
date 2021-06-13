class Player
  attr_accessor :otherPlayer
  attr_reader :board, :isWhite, :pieces, :king, :in_check
  
  # takes in Board and Color module (Color::BLACK or Color::WHITE)
  def initialize(board, color)
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
    @board[row][col] = piece
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
end

class PossibleMove
  attr_reader :from_cell, :to_cell
  def initialize(from_cell, to_cell)
    @from_cell = from_cell
    @to_file = to_cell
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

  def path_empty?(nrow, ncol)
    return false
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
  def initialize(board, color, row, col)
    super(board, color, row, col)
    @has_moved = false
  end
  
  # params indicate desired square to move to
  def can_move(row, col)
    #moving to same square
    return false if (row == @row && col == @col)
    return false if Piece.is_off_board?(row, col)

    row_dist = @isWhite ? @row - row : row - @row
    #moving forward
    if col == @col
      # if there is a piece occupying that square
      return false if @board.piece_at(row, col) != nil
      # 2 sqares first time
      if row_dist == 2 && !@has_moved
        if @isWhite
          return false if @board.piece_at(row, col - 1) != nil || @board.piece_at(row, col - 2) != nil
        else
          return false if @board.piece_at(row, col + 1) != nil || @board.piece_at(row, col + 2) != nil
        end
      # only allow 1 square any other time
      elsif row_dist
        return true
      end
    # diagonal take
    elsif (col - @col).abs() == 1 && row_dist == 1
      #can take if piece exists at spot and if they are of opposite color
      return true if @board.piece_at(file, rank) != nil && @board.piece_at(file, rank).isWhite == !@isWhite
      #set_pos(file, rank) **take piece**
    else
      return false
    end
  end

  def path_empty?(nrow, ncol)
    #moving straight
    if @row == nrow
      if @isWhite
        for i in nrow..@row
          return false if @board.piece_at(i, col) != nil
        end
      else
        for i in @row..nrow
          return false if @board.piece_at(i, col) != nil
        end
      end
    end
    return true
  end

  def possible_moves
    to_ret = []
    dir = @isWhite ? -1 : 1
    #the one right in front of it
    curr = @board.piece_at(row + dir, col)
    to_ret << PossibleMove.new(@board.cell_at(@row, @col), curr) if curr != nil

    if !@has_moved
      # the spot 2 in front of it if it hasn't moved yet
      curr = @board.piece_at(row + 2*dir, col)
      to_ret << PossibleMove.new(@board.cell_at(@row, @col), curr) if curr != nil
    end
    # front-left
    curr = @board.piece_at(row + dir, col - 1)
    to_ret << PossibleMove.new(@board.cell_at(@row, @col), curr) if curr.isWhite == @isWhite
    # front-right
    curr = @board.piece_at(row + dir, col + 1)
    to_ret << PossibleMove.new(@board.cell_at(@row, @col), curr) if curr.isWhite == @isWhite

    return to_ret
  end

  def to_s 
    @isWhite ? "*" : "*".light_blue
  end
end

class Knight < Piece
  def can_move(row, col)
    return false if (row == @row && col == @col)
    return false if is_off_board?(row, col)
    
    if (@row - row).abs + (@col - col).abs == 3
      return @board.piece_at(row, col) == nil || (@board.piece_at(row, col) != nil && @board.piece_at(row, col).isWhite == !@isWhite)
    end
  end

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
  def can_move(row, col)
    return false if is_off_board?(row, col)

    # curr_file = "ABCDEFGH".index(@file)
    # next_file = "ABCDEFGH".index(file)
    # false if it doesn't move
    return false if row == @row && col == @col
    # false if it doesn't move diagnoally
    return false if (@row - row).abs != (@col - col).abs
    # no friendly fire!
    return false if @board.piece_at(row, col) != nil && @board.piece_at(row, col).isWhite == @isWhite

    # checks whether there is any piece blocking the line of sight
    
    return path_empty?(row, col)
  end

  def path_empty?(nrow, ncol)
    horizontal_modifier = @row > nrow ? -1 : 1
    vertical_modifier = @col > ncol ? -1 : 1

    1.upto((@col - ncol).abs - 1) do |i|
      curr = @board.piece_at(@row + i * horizontal_modifier, @col + i * vertical_modifier)
      return false if curr != nil
    end

    return true
  end

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
  def can_move(row, col)
    return false if is_off_board?(row, col)

    return false if (row == @row && col == @col)
    return false if (row != @row && col != @col)
    return false if @board.piece_at(row, col) != nil && @board.piece_at(row, col).isWhite == @isWhite
    # the two statements above confirm that it moves straight either horizontally or vertically
    # now, just need to check whether piece blocking line of sight
    # if moving vertically

    return path_empty?(row, col)
  end

  def path_empty?(nrow, ncol)
    if ncol == @col
      ([@row, nrow].min + 1).upto([@row, nrow].max - 1) do |r|
        curr = @board.piece_at(r, ncol)
        return false if curr != nil
      end
    else
      ([@col, ncol].min + 1).upto([@col, ncol].max - 1) do |c|
        curr = @board.piece_at(nrow, c)
        return false if curr != nil
      end
    end

    return true
  end

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
  def can_move(row, col)
    return false if is_off_board?(row, col)
    return false if (row != @row && col != @col) && (@row - row).abs != (@col - col).abs
    return false if row == @row && col == @col
    return false if @board.piece_at(row, col) != nil && @board.piece_at(row, col).isWhite == @isWhite
    
    return path_empty?(row, col)
  end

  def path_empty?(nrow, ncol)
    if (@row - nrow).abs == (@col - ncol).abs
      # moving diagonally
      horizontal_modifier = @row > nrow ? -1 : 1
      vertical_modifier = @col > ncol ? -1 : 1

      1.upto((@col - ncol).abs - 1) do |i|
        curr = @board.piece_at(@row + i * horizontal_modifier, @col + i * vertical_modifier)
        return false if curr != nil
      end
    elsif ncol == @col && nrow != @row
      # moving vertically
      ([@row, nrow].min + 1).upto([@row, nrow].max - 1) do |r|
        curr = @board.piece_at(r, ncol)
        return false if curr != nil
      end
    elsif nrow == @row && ncol != @col
      # moving horizontally
      ([@col, ncol].min + 1).upto([@col, ncol].max - 1) do |c|
        curr = @board.piece_at(nrow, c)
        return false if curr != nil
      end
    end

    return true
  end

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
  def can_move(row, col)
    return false if row == @row && col == @col
    return false if @board.piece_at(row, col) != nil && @board.piece_at(row, col).isWhite == @isWhite

    return (row - @row).abs <= 1 && (col - @col).abs <= 1
  end

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