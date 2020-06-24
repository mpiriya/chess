require "./lib/chess"

describe Pawn do
  describe "#can_move" do
    it "can move forward two squares on the pawn's first move" do
      b = Board.new
      b.board[6][1] = Pawn.new(b, "white", "B", 2)
      b.move_piece("B", 2, "B", 4)
      expect(b.piece_at("B", 4).to_s).to eql("*")
    end

    it "can take a piece of opposite color that is one diagonal square away" do
      b = Board.new
      b.board[6][1] = Pawn.new(b, "white", "B", 2)
      b.board[5][2] = Pawn.new(b, "black", "C", 3)
      b.move_piece("B", 2, "C", 3)
      expect(b.piece_at("C", 3).to_s).to eql("*")
    end

    it "prevents the Pawn from moving backwards" do
      b = Board.new
      b.board[6][1] = Pawn.new(b, "white", "B", 2)
      
      expect(b.move_piece("B", 2, "B", 1)).to eql(false)
    end
  end
end

describe Knight do
  describe "#can_move" do
    it "doesn't allow moving to current square" do
      b = Board.new
      b.board[7][1] = Knight.new(b, "white", "B", 1)
      expect(b.move_piece("B", 1, "B", 1)).to eql(false)
    end

    it "moves 2 vertically and 1 horizontally" do
      b = Board.new
      b.board[7][1] = Knight.new(b, "white", "B", 1)
      b.move_piece("B", 1, "C", 3)
      expect(b.piece_at("C", 3).to_s).to eql("N")
    end

    it "move 1 vertically and 2 horizontally" do
      b = Board.new
      b.board[0][1] = Knight.new(b, "black", "B", 8)
      b.move_piece("B", 8, "C", 6)
      expect(b.piece_at("C", 6).to_s).to eql("\e[36mN\e[0m")
    end

    it "catches illegal moves" do
      b = Board.new
      b.board[7][1] = Knight.new(b, "white", "B", 1)
      expect(b.move_piece("B", 1, "B", 4)).to eql(false)
    end
  end
end