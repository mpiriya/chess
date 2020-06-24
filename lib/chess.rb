class Board
  attr_accessor :board
  def initialize
    @board = Array.new(8) {Array.new(8, " ")}
  end

  # move from a_file, a_rank to b_file, b_rank
  def move_piece(a_file, a_rank, b_file, b_rank)
    if piece_at(a_file, a_rank) != " " && piece_at(a_file, a_rank).can_move(b_file, b_rank)
      @board[8 - a_rank]["ABCDEFGH".index(a_file)].set_pos(b_file, b_rank)
      return true
    else
      return false
    end
  end

  def piece_at(file, rank)
    return @board[8 - rank]["ABCDEFGH".index(file)]
  end

  def to_s
    to_ret = "-"*31 + "\n "
    @board.each { |elem| to_ret += "#{elem.join(" | ")}\n" + "-"*31 + "\n "}
    to_ret
  end
end

class Piece
  attr_writer :file, :rank

  def initialize(board, color, file, rank)
    @board = board
    color == "white" ? @white = true : @white = false
    @rank = rank
    @file = file
  end

  def set_pos(file, rank)
    @board.board[8 - @rank]["ABCDEFGH".index(@file)] = " "
    @file = file
    @rank = rank
    @board.board[8 - rank]["ABCDEFGH".index(file)] = self
  end

  def is_off_board?(file, rank)
    return "ABCDEFGH".index(file) == -1 || rank < 1 || rank > 8
  end
end

class Pawn < Piece
  attr_reader :file, :rank, :white

  def initialize(board, color, file, rank)
    super(board, color, file, rank)
    @has_moved = false
  end
  
  # params indicate desired square to move to
  def can_move(file, rank)
    #moving to same square
    return false if (file == @file && rank == @rank)
    return false if is_off_board?(file, rank)
    
    curr_file_num = "ABCDEFGH".index(@file)
    desired_file_num = "ABCDEFGH".index(file)
    #moving forward
    if file == @file
      return false if @board.piece_at(file, rank) != " "
      # 2 sqares first time      
      if (@white && @rank == 2 && rank == 4) || (!@white && @rank == 7 && rank == 5)
        return true
      # only allow 1 square any other time
      elsif (@white && rank - @rank == 1) || (!@white && @rank - rank == 1)
        return true
      end
    # diagonal take
    elsif (curr_file_num - desired_file_num).abs == 1 && ((rank - @rank == 1 && @white) || (@rank - rank == 1 && !@white))
      #can take if piece exists at spot and if they are of opposite color
      return true if @board.piece_at(file, rank) != " " && @board.piece_at(file, rank).white == !@white
      #set_pos(file, rank) **take piece**
    else
      return false
    end
  end

  def to_s 
    @white ? "*" : "*".light_blue
  end
end

class Knight < Piece
  def can_move(file, rank)
    return false if (file == @file || rank == @rank)
    return false if is_off_board?(file, rank)
    
    curr_file = "ABCDEFGH".index(@file)
    next_file = "ABCDEFGH".index(file)
    if (curr_file - next_file).abs + (@rank - rank).abs == 3
      return @board.piece_at(file, rank) == " " || (@board.piece_at(file, rank) != " " && @board.piece_at(file, rank).white == !@white)
    end
  end

  def to_s
    @white ? "N" : "N".light_blue
  end
end

class Bishop < Piece
  def can_move(file, rank)
    return false if is_off_board?(file, rank)

    curr_file = "ABCDEFGH".index(@file)
    next_file = "ABCDEFGH".index(file)
    # false if it doesn't move
    return false if (file == @file || rank == @rank)
    # false if it doesn't move diagnoally
    return false if (curr_file - next_file).abs != (@rank - rank).abs
    # no friendly fire!
    return false if @board.piece_at(file, rank) != " " && @board.piece_at(file, rank).white == @white

    # checks whether there is any piece blocking the line of sight
    
    horizontal_modifier = (curr_file > next_file ? -1 :  1)
    vertical_modifier = (@rank > rank ? -1 : 1)
    
    1.upto((@rank - rank).abs - 1) do |i|
      if @board.piece_at("ABCDEFGH"[curr_file + i * horizontal_modifier], @rank + i * vertical_modifier) != " "
        return false
      end
    end
    return true
  end

  def to_s
    @white ? "B" : "B".light_blue
  end
end

class Rook < Piece
  def can_move(file, rank)
    return false if is_off_board?(file, rank)

    return false if (file == @file && rank == @rank)
    return false if (file != @file && rank != @rank)
    return false if @board.piece_at(file, rank) != " " && @board.piece_at(file, rank).white == @white
    # the two statements above confirm that it moves straight either horizontally or vertically
    # now, just need to check whether piece blocking line of sight
    # if moving vertically

    if file == @file
      # moving vertically
      ([@rank, rank].min + 1).upto([@rank, rank].max - 1) do |r|
        return false if @board.piece_at(file, r) != " "
      end
    else
      # moving horizontally 
      curr_file = "ABCDEFGH".index(@file)
      next_file = "ABCDEFGH".index(file)
      ([curr_file, next_file].min + 1).upto([curr_file, next_file].max - 1) do |f|
        return false if @board.piece_at("ABCDEFGH"[f], rank) != " "
      end
    end
    return true
  end

  def to_s
    @white ? "R" : "R".light_blue
  end
end

class Queen < Piece

end

class King < Piece
  
end

class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def blue
    colorize(34)
  end

  def pink
    colorize(35)
  end

  def light_blue
    colorize(36)
  end
end