module day24
include("day24_objects.jl")

ENV["JULIA_DEBUG"] = all

@debug "args: $(join(ARGS,","))"
input = filter(
  str -> length(str) > 0,
  readlines(ARGS[1])
)

valley = parse_valley(input)
@info valley

function traverse(valley::Valley, start::Position, finish::Position)
  positions = [start]

  min = 0
  while !(finish in positions)
    spots = free_spots(valley)
    newPositions = Set{Position}()
    validPositions = Set{Position}()
    for position in positions
      if in(position, spots)
        push!(validPositions, position)
        for dir in instances(Direction)
          push!(newPositions, direction_to_offset(dir) + position)
        end
        push!(newPositions, position)
      end
    end
    @debug "min $(min): $(length(validPositions)) valid positions found"
    min = min + 1
    valley = move_storms(valley)
    positions = newPositions

  end
  return valley
end

valley = traverse(valley, Position(1, 0), Position(valley.x, valley.y + 1))
@info valley
valley = traverse(valley, Position(valley.x, valley.y + 1), Position(1, 0))
@info valley
valley = traverse(valley, Position(1, 0), Position(valley.x, valley.y + 1))
@info valley

end; # module day24
