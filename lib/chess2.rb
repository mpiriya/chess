class Player
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

  def make_move(piece, row, col) {
    
  }
end

class PossibleMove
  attr_reader :piece, :to_cell
  def initialize(piece, to_cell)
    @piece = piece
    @to_file = to_cell
  end
end

class Board 
  attr_accessor :board
  attr_reader :white_player, :black_player, :current_player

  def initialize
    @board = Array.new(8) {|r| Array.new(8) {|c| Cell.new(nil, r, c)}}
    @white_player = Player.new(this, "white")
    @black_player = Player.new(this, "black")
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

class Piece
  attr_reader :isWhite
  attr_accessor :row, :col, :available_squares

  def initialize(board, color, row, col)
    @board = board
    @isWhite = color == "white"
    @row = row
    @col = col
  end

  def set_pos(row, col)
    @board.set_piece(row, col, nil)
    @row = row
    @col = col
    @board.set_piece(row, col, self)
  end

  def self.is_off_board?(row, col)
    return row < 0 || row > 7 || col < 0 || col > 7
  end

  def in_path(nrow, ncol)
    return false
  end

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
      to_ret << curr
      i += 1
      curr = @board.piece_at(@row + delta_row * i, @col + delta_col * i)
    end
    if curr.isWhite != @isWhite
      to_ret << curr
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

  def in_path(nrow, ncol)
    to_ret = []
    #moving straight
    if @row == nrow
      if @isWhite
        for i in nrow..@row
          if @board.piece_at(i, col) != nil
            to_ret << @board.piece_at(i, col)
          end
        end
      else
        for i in @row..nrow
          if @board.piece_at(i, col) != nil
            to_ret << @board.piece_at(i, col)
          end
        end
      end
    end
    return to_ret
  end

  def possible_moves
    to_ret = []
    dir = @isWhite ? -1 : 1
    #the one right in front of it
    curr = @board.piece_at(row + dir, col)
    to_ret << curr if curr != nil

    if !@has_moved
      # the spot 2 in front of it if it hasn't moved yet
      curr = @board.piece_at(row + 2*dir, col)
      to_ret << curr if curr != nil
    end
    # front-left
    curr = @board.piece_at(row + dir, col - 1)
    to_ret << curr if curr.isWhite == @isWhite
    # front-right
    curr = @board.piece_at(row + dir, col + 1)
    to_ret << curr if curr.isWhite == @isWhite

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
    to_ret << curr if curr == nil || curr.isWhite != @isWhite
    # up-right
    curr = @board.piece_at(@row - 2, @col + 1)
    to_ret << curr if curr == nil || curr.isWhite != @isWhite
    # down-left
    curr = @board.piece_at(@row + 2, @col - 1)
    to_ret << curr if curr == nil || curr.isWhite != @isWhite
    # down-right
    curr = @board.piece_at(@row + 2, @col + 1)
    to_ret << curr if curr == nil || curr.isWhite != @isWhite
    # left-up
    curr = @board.piece_at(@row - 1, @col - 2)
    to_ret << curr if curr == nil || curr.isWhite != @isWhite
    # left-down
    curr = @board.piece_at(@row + 1, @col - 2)
    to_ret << curr if curr == nil || curr.isWhite != @isWhite
    # right-up
    curr = @board.piece_at(@row - 1, @col + 2)
    to_ret << curr if curr == nil || curr.isWhite != @isWhite
    # right-down
    curr = @board.piece_at(@row + 1, @col + 2)
    to_ret << curr if curr == nil || curr.isWhite != @isWhite

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
    
    return in_path(row, col).empty?
  end

  def in_path(nrow, ncol)
    to_ret = []
    horizontal_modifier = @row > nrow ? -1 : 1
    vertical_modifier = @col > ncol ? -1 : 1

    1.upto((@col - ncol).abs - 1) do |i|
      curr = @board.piece_at(@row + i * horizontal_modifier, @col + i * vertical_modifier)
      if curr != nil
        to_ret << curr
      end
    end

    return to_ret
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

    return in_path(row, col).empty?
  end

  def in_path(nrow, ncol)
    to_ret = []

    if ncol == @col
      ([@row, nrow].min + 1).upto([@row, nrow].max - 1) do |r|
        curr = @board.piece_at(r, ncol)
        to_ret << curr if curr != nil
      end
    else
      ([@col, ncol].min + 1).upto([@col, ncol].max - 1) do |c|
        curr = @board.piece_at(nrow, c)
        to_ret << curr if curr != nil
      end
    end

    return to_ret
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
    
    return in_path(row, col).empty?
  end

  def in_path(nrow, ncol)
    to_ret = []

    if (@row - nrow).abs == (@col - ncol).abs
      # moving diagonally
      horizontal_modifier = @row > nrow ? -1 : 1
      vertical_modifier = @col > ncol ? -1 : 1

      1.upto((@col - ncol).abs - 1) do |i|
        curr = @board.piece_at(@row + i * horizontal_modifier, @col + i * vertical_modifier)
        if curr != nil
          to_ret << curr
        end
      end
    elsif ncol == @col && nrow != @row
      # moving vertically
      ([@row, nrow].min + 1).upto([@row, nrow].max - 1) do |r|
        curr = @board.piece_at(r, ncol)
        to_ret << curr if curr != nil
      end
    elsif nrow == @row && ncol != @col
      # moving horizontally
      ([@col, ncol].min + 1).upto([@col, ncol].max - 1) do |c|
        curr = @board.piece_at(nrow, c)
        to_ret << curr if curr != nil
      end
    end

    return to_ret
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
  def in_check(row, col)
    if @isWhite
      @board.black.each {|piece| return true if piece.can_move(row, col)}
    else
      @board.white.each {|piece| return true if piece.can_move(row, col)}
    end
    return false
  end

  def can_move(row, col)
    return false if row == @row && col == @col
    return false if @board.piece_at(row, col) != nil && @board.piece_at(row, col).isWhite == @isWhite
    return false if in_check(file, rank)

    return (row - @row).abs <= 1 && (col - @col).abs <= 1
  end

  def to_s
    @isWhite ? "K" : "K".light_blue
  end
end