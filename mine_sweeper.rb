require "yaml"

class Tile
  
  attr_accessor :bombed, :flagged
  def initialize(position, board)
    @bombed = false
    @flagged = false
    @revealed = false
    @position = position
    @board = board
  end
  
  def bombed?
    @bombed
  end
  
  def flagged?
    @flagged
  end
  
  def toggle_flag
    @flagged = (@flagged == true) ? false : true
  end
  
  def revealed?
    @revealed
  end
  
  def reveal!
    @revealed = true
    if neighbor_bomb_count > 0
      return nil
    else
      self.neighbors.each do |neighbor|
        neighbor.reveal! unless neighbor.revealed?
      end
    end
  end
  
  DIRECTIONS = [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]]
  
  # returns array of tiles
  # [tile1, tile2, ...tile9]
  def neighbors    
    neighbors_array = []
    n = []
    
    DIRECTIONS.each do |i|
      n << [@position[0] + i[0], @position[1] + i[1]]
    end
    
    @neighbors_positions = n.select {|neighbor| neighbor[0] < 9 && neighbor[1] < 9 && neighbor[0] >= 0 && neighbor[1] >= 0 }
   
    @neighbors_positions.each do |position|
      neighbors_array << @board.tiles[position[0]][position[1]]
    end  
    neighbors_array
  end
 
  def neighbor_bomb_count
    neighbors_array = neighbors
    sum = 0
    neighbors_array.each do |tile|
      if tile.bombed?
        sum += 1
      end
    end
    sum
  end

  def inspect
    if @flagged
      return "F"
    end
    

    if @revealed
      return neighbor_bomb_count if neighbor_bomb_count > 0
      return "B" if @bombed    
      return "_"
    end
    return "*"
  end
end

class Board
  LENGTH = 9

  attr_accessor :tiles, :bombs
  
  def initialize(bombs)
    # [[tile1, tile2, ...], [tile10, tile11, ]]
    @tiles = Array.new(LENGTH){ Array.new(LENGTH) }
    for i in 0..LENGTH-1
      for j in 0..LENGTH-1
        @tiles[i][j] = Tile.new([i, j], self)
      end
    end
    @bombs = bombs    
    bomb_setter
  end
  
  def bomb_setter
    bomb_locations = []
    until bomb_locations.length == @bombs
      x = rand(LENGTH)
      y = rand(LENGTH)
      bomb_locations << [x, y] unless bomb_locations.include?([x,y])
      @tiles[x][y].bombed = true
    end
    bomb_locations
  end  
    
 
  def print_board
    @tiles.each do |row|
      row.each do |tile|
        print tile.inspect
        print " "

      end
      print "\n"
    end
  end
  
  def revealed_array
    
    revealed = []
    @tiles.each do |row|
      row.each do |tile|
        if tile.revealed?
          revealed << tile.inspect
        end
      end
    end
    revealed
    
  end

end
board = Board.new(5)


class Game
  attr_accessor :board
  
  def initialize(board)
    @board = board
  end
  
  def win?
    # revealed = squares - bombs (71)
    if lose?
      return false
    end   
    if @board.revealed_array.length == 81 - @board.bombs
      return true
    end
    false
  end
  
  def lose?
    if @board.revealed_array.include?("B")
      return true
    end
    false
  end
  
  def run
    print "Load Game? (Y/N): "
    if gets.chomp == "Y"
      print "Filename: "
      load_file = gets.chomp()
      load(load_file)
    end
    
    start = Time.now
    until win? || lose?
      @board.print_board
      print "Input Tile (x, y) and Action ('F', 'S'): "
      input = gets.chomp.split(" ")
      
      # command: S filename
      if input[0] == 'S'
        save(input[1])
      elsif input[2] == 'F'
        x = input[0].to_i
        y = input[1].to_i
        @board.tiles[x][y].toggle_flag
      else
        x = input[0].to_i
        y = input[1].to_i
        @board.tiles[x][y].reveal!
      end
    end
    if win?
      puts "You win in #{ Time.now - start } seconds"
      
    else
      puts "You lose"
      @board.print_board
    end
  end
  
  # command: save save.txt
  def save(filename)
    p filename
    f = File.new(filename, 'w')
    f.puts self.to_yaml  
    
    f.close
  end
  
  def load(filename)
    @board = YAML::load(File.open(filename)).board
  end 
    
end


Game.new(board).run


