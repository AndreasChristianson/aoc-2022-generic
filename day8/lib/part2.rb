file = File.open("input.txt")
lines = file.readlines.map(&:chomp)

grid = Hash.new

class Tree
  def initialize(height)
    @height = height
    @visible = false
    @view = 1
  end

  attr_reader :height, :visible, :view
  attr_accessor :visible, :view
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
  for col in 0..width - 1
    print "#{grid[[row, col]].height}|"
  end
  puts
end
puts "****"

for row in 0..height - 1
  for col in 0..width - 1
    target = grid[[row, col]]
    for left in 1..col
      if grid[[row, col - left]].height >= target.height or col - left == 0
        target.view *= left
        break
      end
    end
    for right in 1..width - col -1
      if grid[[row, col + right]].height >= target.height or col + right == width - 1
        target.view *= right
        break
      end
    end
    for up in 1..row 
      if grid[[row - up, col]].height >= target.height or row - up == 0
        target.view *= up

        break
      end
    end
    for down in 1..height - row -1
      if grid[[row + down, col]].height >= target.height or row + down == height - 1
        target.view *= down
        break
      end
    end
  end
end

puts grid
    .map { |key, value| value.view }
    .max()
