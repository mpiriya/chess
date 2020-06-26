class Board
  attr_accessor :board
  attr_reader :white, :black
  def initialize
    @board = Array.new(8) {Array.new(8, " ")}
    setup_pieces
  end

  # move from a_file, a_rank to b_file, b_rank
  def move_piece(isWhite, a_file, a_rank, b_file, b_rank)
    if piece_at(a_file, a_rank) != " " && piece_at(a_file, a_rank).white == isWhite && piece_at(a_file, a_rank).can_move(b_file, b_rank)
      @board[8 - a_rank]["ABCDEFGH".index(a_file)].set_pos(b_file, b_rank)
      if king_under_attack(isWhite)
        @board[8 - b_rank]["ABCDEFGH".index(b_file)].set_pos(a_file, a_rank)
        return false
      end
      if king_under_attack(!isWhite)
        puts "CHECK"
      end
      return true
    else
      return false
    end
  end

  def setup_pieces
    @white = Array.new
    8.times {|i| @white << Pawn.new(self, "white", "ABCDEFGH"[i-1], 2)}
    @white << Rook.new(self, "white", "A", 1)
    @white << Knight.new(self, "white", "B", 1)
    @white << Bishop.new(self, "white", "C", 1)
    @white << Queen.new(self, "white", "D", 1)
    @white_king = King.new(self, "white", "E", 1)
    @white << @white_king
    @white << Bishop.new(self, "white", "F", 1)
    @white << Knight.new(self, "white", "G", 1)
    @white << Rook.new(self, "white", "H", 1)

    @black = Array.new
    8.times {|i| @black << Pawn.new(self, "black", "ABCDEFGH"[i-1], 7)}
    @black << Rook.new(self, "black", "A", 8)
    @black << Knight.new(self, "black", "B", 8)
    @black << Bishop.new(self, "black", "C", 8)
    @black << Queen.new(self, "black", "D", 8)
    @black_king = King.new(self, "black", "E", 8)
    @black << @black_king
    @black << Bishop.new(self, "black", "F", 8)
    @black << Knight.new(self, "black", "G", 8)
    @black << Rook.new(self, "black", "H", 8)
    
    @white.each {|elem| @board[8-elem.rank]["ABCDEFGH".index(elem.file)] = elem}
    @black.each {|elem| @board[8-elem.rank]["ABCDEFGH".index(elem.file)] = elem}
  end

  def king_under_attack(isWhite)
    if isWhite
      @black.each {|elem| return true if elem != @black_king && elem.can_move(@white_king.file, @white_king.rank)}
    else
      @white.each {|elem| return true if elem != @white_king && elem.can_move(@black_king.file, @black_king.rank)}
    end
    return false
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
  attr_reader :white
  attr_accessor :file, :rank

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
  def can_move(file, rank)
    return false if rank == @rank && file == @file
    return false if @board.piece_at(file, rank) != " " && @board.piece_at(file, rank).white == @white
    curr_file = "ABCDEFGH".index(@file)
    next_file = "ABCDEFGH".index(file)
    
    if (curr_file - next_file).abs == (@rank - rank).abs
      #moving diagonally
      horizontal_modifier = (curr_file > next_file ? -1 :  1)
      vertical_modifier = (@rank > rank ? -1 : 1)
      1.upto((@rank - rank).abs - 1) do |i|
        if @board.piece_at("ABCDEFGH"[curr_file + i * horizontal_modifier], @rank + i * vertical_modifier) != " "
          return false
        end
      end
      return true
    elsif file == @file && rank != @rank
      # moving vertically
      ([@rank, rank].min + 1).upto([@rank, rank].max - 1) do |r|
        return false if @board.piece_at(file, r) != " "
      end
      return true
    elsif rank == @rank && file != @file
      # moving horizontally
      ([curr_file, next_file].min + 1).upto([curr_file, next_file].max - 1) do |f|
        return false if @board.piece_at("ABCDEFGH"[f], rank) != " "
      end
      return true
    end
    return false
  end

  def to_s
    @white ? "Q" : "Q".light_blue
  end
end

class King < Piece
  def in_check(file, rank)
    if @white
      @board.black.each {|piece| return true if piece.can_move(file, rank)}
    else
      @board.white.each {|piece| return true if piece.can_move(file, rank)}
    end
    return false
  end

  def can_move(file, rank)
    return false if file == @file && rank == @rank
    return false if @board.piece_at(file, rank) != " " && @board.piece_at(file, rank).white == @white
    return false if in_check(file, rank)
    curr_file = "ABCDEFGH".index(@file)
    next_file = "ABCDEFGH".index(file)
    return (curr_file - next_file).abs <= 1 && (@rank - rank).abs <= 1
  end

  def to_s
    @white ? "K" : "K".light_blue
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