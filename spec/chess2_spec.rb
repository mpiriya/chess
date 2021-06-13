require "./lib/chess2.rb"

describe Pawn do
  describe "#possible_moves" do
    it "doesn't allow moving to the current square" do

    end

    it "allows Pawn to move one square forward" do

    end

    it "allows Pawn to move two squares forward on first move" do

    end

    it "doesn't allow Pawn to move on top of another piece" do

    end

    it "doesn't allow Pawn to jump over another piece" do

    end
    
    it "captures diagonally" do

    end

    it "doesn't capture allies" do

    end

    it "cannot move backwards" do 

    end
  end
end

describe Knight do
  describe "#possible_moves" do
    it "doesn't allow moving to the current square" do

    end

    it "allows moving 2 vertically and 1 horizontally" do
      
    end

    it "allows moving 1 vertically and 2 horizontally" do
      
    end

    it "catches illegal moves" do
      
    end

    it "can capture enemies" do
      
    end
  end
end

describe Bishop do
  describe "#possible_moves" do
    it "doesn't allow moving to current square" do
      
    end

    it "moves diagonally" do
      
    end

    it "prevents non diagonal moves" do
      
    end

    it "doesn't move through enemies" do
      
    end

    it "doesn't capture allies" do
      
    end

    it "doesn't move through allies" do
      
    end

    it "can capture enemies" do
      
    end
  end
end

describe Rook do
  describe "#possible_moves" do
    it "prevents moving nowhere" do
      
    end

    it "prevents moving rank AND file" do
      
    end
    
    it "doesn't move through allies" do
      
    end

    it "doesn't move through enemies" do
      
    end

    it "doesn't take allies" do
      
    end

    it "takes enemies" do
      
    end
  end
end

describe Queen do
  describe "#possible_moves" do
    it "doesn't allow moving to current square" do
      
    end

    it "moves diagonally" do
      
    end

    it "moves vertically" do

    end

    it "moves horizontally" do
      
    end

    it "prevents illegal moves" do
      
    end

    it "doesn't move through enemies" do
      
    end

    it "doesn't capture allies" do
      
    end

    it "doesn't move through allies" do
      
    end

    it "can capture enemies" do
      
    end
  end
end