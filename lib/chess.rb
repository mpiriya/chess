class Board
  attr_accessor :board
  def initialize
    @board = Array.new(8) {Array.new(8, " ")}
    @board[6] = Array.new(8) {|i| Pawn.new(self, "black", "ABCDEFGH"[i], 7)}
  end

  # move from a_file, a_rank to b_file, b_rank
  def move_piece(a_file, a_rank, b_file, b_rank)
    if @board[a_rank - 1]["ABCDEFGH".index(a_file)].can_move(b_file, b_rank)
      @board[b_rank - 1]["ABCDEFGH".index(b_file)] = @board[a_rank - 1]["ABCDEFGH".index(a_file)]
      @board[a_rank - 1]["ABCDEFGH".index(a_file)] = " "
      @board[b_rank - 1]["ABCDEFGH".index(b_file)].file = b_file
      @board[b_rank - 1]["ABCDEFGH".index(b_file)].rank = b_rank
      @board[b_rank - 1]["ABCDEFGH".index(b_file)].set_pos(0,0)
    end
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
    puts @board
  end
end

class Pawn < Piece
  attr_reader :file, :rank

  def initialize(board, color, file, rank)
    super(board, color, file, rank)
    @has_moved = false
  end
  
  # params indicate desired square to move to
  def can_move(file, rank)
    #moving to same square
    return false if (file == @file && rank == @rank)
    #moving forward
    if file == @file
      # 2 sqares first time      
      if (@white && @rank == 2 && rank == 4) || (!@white && @rank == 7 && rank == 5)
        return true
      # only allow 1 square any other time
      elsif (@white && rank - @rank == 1) || (!@white && @rank - rank == 1)
        return true
      end
    # diagonal take
    elsif (@file - file).abs == 1 && ((@rank - rank == 1 && @white) || (rank - @rank == 1 && !@white))
      #set_pos(file, rank) **take piece**
    else
      return false
    end
  end

  def to_s 
    @white ? "*" : "*".light_blue
  end
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

b = Board.new
puts b
b.move_piece("A", 7, "A", 5)
#puts b
b.move_piece("A", 5, "A", 4)
#puts b