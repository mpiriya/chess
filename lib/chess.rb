class Board
  attr_accessor :board
  def initialize
    @board = Array.new(8) {Array.new(8, " ")}
  end

  # move from a_file, a_rank to b_file, b_rank
  def move_piece(a_file, a_rank, b_file, b_rank)
    if piece_at(a_file, a_rank) != " " && piece_at(a_file, a_rank).can_move(b_file, b_rank)
      @board[8 - a_rank]["ABCDEFGH".index(a_file)].set_pos(b_file, b_rank)
    else
      puts "INVALID MOVE"
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
  def initialize(board, color, file, rank)
    super(board, color, file, rank)
  end

  def can_move(file, rank)
    return false if (file == @file && rank == @rank)


  end
end

class Bishop < Piece

end

class Rook < Piece

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