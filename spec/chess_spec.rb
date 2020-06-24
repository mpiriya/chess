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
  end

end