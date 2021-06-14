require "./lib/chess2.rb"

describe Pawn do
  describe "#possible_moves" do
    it "doesn't allow moving to the current square" do
      b = Board.new
      p = Pawn.new(b, "white", 6, 6)
      b.set_piece(p.row, p.col, p)
      poss = p.possible_moves
      expect(poss.any? {|m| m.to_cell.row == 6 && m.to_cell.col == 6}).to eql(false)
    end

    it "allows Pawn to move one square forward" do
      b = Board.new
      p = Pawn.new(b, "white", 6, 6)
      b.set_piece(p.row, p.col, p)
      poss = p.possible_moves
      expect(poss.any? {|m| m.to_cell.row == 5 && m.to_cell.col == 6}).to eql(true)
    end

    it "allows Pawn to move two squares forward on first move" do
      b = Board.new
      p = Pawn.new(b, "white", 6, 6)
      b.set_piece(p.row, p.col, p)
      poss = p.possible_moves
      expect(poss.any? {|m| m.to_cell.row == 4 && m.to_cell.col == 6}).to eql(true)
    end

    it "doesn't allow Pawn to move on top of another piece" do
      b = Board.new
      p = Pawn.new(b, "white", 6, 6)
      p2 = Pawn.new(b, "black", 5, 6)
      b.set_piece(p.row, p.col, p)
      b.set_piece(p2.row, p2.col, p2)
      poss = p.possible_moves
      expect(poss.any? {|m| m.to_cell.row == 5 && m.to_cell.col == 6}).to eql(false)
    end

    it "doesn't allow Pawn to jump over another piece" do
      b = Board.new
      p = Pawn.new(b, "white", 6, 6)
      p2 = Pawn.new(b, "black", 5, 6)
      b.set_piece(p.row, p.col, p)
      b.set_piece(p2.row, p2.col, p2)
      poss = p.possible_moves
      expect(poss.any? {|m| m.to_cell.row == 4 && m.to_cell.col == 6}).to eql(false)
    end
    
    it "captures diagonally" do
      b = Board.new
      p = Pawn.new(b, "white", 6, 6)
      p2 = Pawn.new(b, "black", 5, 5)
      b.set_piece(p.row, p.col, p)
      b.set_piece(p2.row, p2.col, p2)
      poss = p.possible_moves
      expect(poss.any? {|m| m.to_cell.row == 5 && m.to_cell.col == 5}).to eql(true)
    end

    it "doesn't capture allies" do
      b = Board.new
      p = Pawn.new(b, "white", 6, 6)
      p2 = Pawn.new(b, "white", 5, 5)
      b.set_piece(p.row, p.col, p)
      b.set_piece(p2.row, p2.col, p2)
      poss = p.possible_moves
      expect(poss.any? {|m| m.to_cell.row == 5 && m.to_cell.col == 5}).to eql(false)
    end

    it "cannot move backwards" do 
      b = Board.new
      p = Pawn.new(b, "white", 6, 6)
      b.set_piece(p.row, p.col, p)
      poss = p.possible_moves
      expect(poss.any? {|m| m.to_cell.row == 7 && m.to_cell.col == 6}).to eql(false)
    end
  end
end

# describe Knight do
#   describe "#possible_moves" do
#     it "doesn't allow moving to the current square" do

#     end

#     it "allows moving 2 vertically and 1 horizontally" do
      
#     end

#     it "allows moving 1 vertically and 2 horizontally" do
      
#     end

#     it "catches illegal moves" do
      
#     end

#     it "can capture enemies" do
      
#     end
#   end
# end

# describe Bishop do
#   describe "#possible_moves" do
#     it "doesn't allow moving to current square" do
      
#     end

#     it "moves diagonally" do
      
#     end

#     it "prevents non diagonal moves" do
      
#     end

#     it "doesn't move through enemies" do
      
#     end

#     it "doesn't capture allies" do
      
#     end

#     it "doesn't move through allies" do
      
#     end

#     it "can capture enemies" do
      
#     end
#   end
# end

# describe Rook do
#   describe "#possible_moves" do
#     it "prevents moving nowhere" do
      
#     end

#     it "prevents moving rank AND file" do
      
#     end
    
#     it "doesn't move through allies" do
      
#     end

#     it "doesn't move through enemies" do
      
#     end

#     it "doesn't take allies" do
      
#     end

#     it "takes enemies" do
      
#     end
#   end
# end

# describe Queen do
#   describe "#possible_moves" do
#     it "doesn't allow moving to current square" do
      
#     end

#     it "moves diagonally" do
      
#     end

#     it "moves vertically" do

#     end

#     it "moves horizontally" do
      
#     end

#     it "prevents illegal moves" do
      
#     end

#     it "doesn't move through enemies" do
      
#     end

#     it "doesn't capture allies" do
      
#     end

#     it "doesn't move through allies" do
      
#     end

#     it "can capture enemies" do
      
#     end
#   end
# end