file = File.open("input.txt")
lines = file.readlines.map(&:chomp)

grid = Hash.new

class Tree
  def initialize(height)
    @height = height
    @visible = false
  end

  attr_reader :height, :visible
  attr_accessor :visible
end

width = lines[0].length
height = lines.length()
puts "width: #{width}, height: #{height}"

lines.each_with_index do |line, row|
  line.split("").each_with_index do |item, col|
    grid[[row, col]] = Tree.new(Integer(item))
  end
end

for row in 0..height - 1
  tallest = grid[[row, 0]].height
  grid[[row, 0]].visible = true
  (0..(width - 1)).each do |col|
    if tallest == 9
      break
    end
    if tallest < grid[[row, col]].height
      grid[[row, col]].visible = true
      tallest = grid[[row, col]].height
    end
  end
  tallest = grid[[row, width-1]].height
  grid[[row, width-1]].visible = true
  (0..(width - 1)).reverse_each do |col|
    if tallest == 9
      break
    end
    if tallest < grid[[row, col]].height
      grid[[row, col]].visible = true
      tallest = grid[[row, col]].height
    end
  end
end


for col in 0..width - 1
  tallest = grid[[0, col]].height
  grid[[0, col]].visible = true
  (0..(height - 1)).each do |row|
    if tallest == 9
      break
    end
    if tallest < grid[[row, col]].height
      grid[[row, col]].visible = true
      tallest = grid[[row, col]].height
    end
  end
  tallest = grid[[height-1, col]].height
  grid[[height-1, col]].visible = true
  (0..(height - 1)).reverse_each do |row|
    if tallest == 9
      break
    end
    if tallest < grid[[row, col]].height
      grid[[row, col]].visible = true
      tallest = grid[[row, col]].height
    end
  end
end

for col in 0..width - 1
  for row in 0..height - 1
    if grid[[row, col]].visible
      print 'V'
    else
      print '.'
    end
  end
  puts
end
puts grid
  .map{ |key,value| value.visible }
  .select{|bool| bool}
  .count()