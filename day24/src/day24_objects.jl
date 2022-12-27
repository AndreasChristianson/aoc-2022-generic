using Pkg
Pkg.add("AutoHashEquals")
using AutoHashEquals

import Base.:+
import Base.show



@enum Direction begin
  north
  south
  east
  west
end

@auto_hash_equals struct Position
  x::Int
  y::Int
end

(+)(l::Position, r::Position) = Position(l.x + r.x, l.y + r.y)

struct Storm
  direction::Direction
  position::Position
end

struct Valley
  x::Int
  y::Int
  storms::Vector{Storm}
  turn::Int
end

function parse_direction(input::AbstractString)
  if input == "^"
    return north
  end
  if input == "<"
    return west
  end
  if input == ">"
    return east
  end
  if input == "v"
    return south
  end
end


function to_string(d::Direction)
  if d == north
    return "^"
  elseif d == south
    return "v"
  elseif d == west
    return "<"
  elseif d == east
    return ">"
  end
end

northwards = Position(0, -1)
southhwards = Position(0, 1)
westwards = Position(-1, 0)
eastwards = Position(1, 0)

function direction_to_offset(dir::Direction)
  if dir == north
    return northwards
  end
  if dir == south
    return southhwards
  end
  if dir == west
    return westwards
  end
  if dir == east
    return eastwards
  end
end



function move_storms(v::Valley)
  storms = []

  for storm in v.storms
    new_pos = wrap(v, storm.position + direction_to_offset(storm.direction))

    push!(
      storms,
      Storm(storm.direction, new_pos)
    )
  end

  return Valley(
    v.x,
    v.y,
    storms,
    v.turn + 1
  )
end

function wrap(v::Valley, oldPos::Position)
  if oldPos.x > valley.x
    return Position(1, oldPos.y)
  end
  if oldPos.x < 1
    return Position(v.x, oldPos.y)
  end
  if oldPos.y > valley.y
    return Position(oldPos.x, 1)
  end
  if oldPos.y < 1
    return Position(oldPos.x, v.y)
  end

  return oldPos
end

function parse_valley(input::Vector{String})
  storms = []
  col = 1
  row = 1

  y = length(input) - 2
  x = 0
  for line in @view input[2:end-1]
    x = length(line) - 2
    for char in @view split(line, "")[2:end-1]
      if char != "."
        push!(storms, Storm(parse_direction(char), Position(col, row)))
      end
      col = col + 1
    end
    col = 1
    row = row + 1
  end

  return Valley(
    x,
    y,
    storms,
    0
  )
end

function free_spots(v::Valley)
  ret = Set{Position}()
  push!(ret, Position(1,0), Position(v.x,v.y+1))

  for x in 1:v.x
    for y in 1:v.y
      push!(ret, Position(x, y))
    end
  end

  for storm in v.storms
    delete!(ret, storm.position)
  end

  return ret
end

function Base.show(io::IO, v::Valley)
  ret = ""
  spots = free_spots(v)
  for y in 0:v.y+1
    for x in 0:v.x+1
      stormCount = 0
      pos = Position(x, y)
      dir = ""
      for storm in v.storms
        if storm.position == pos
          stormCount = stormCount + 1
          dir = storm.direction
        end
      end
      if stormCount == 1
        ret = "$(ret)$(to_string(dir))"
      elseif stormCount>1
        ret = "$(ret)$(stormCount%10)"
      elseif pos in spots
        ret = "$(ret)."
      elseif pos.x<1 || pos.x>valley.x ||pos.y<1 || pos.y>valley.y
        ret = "$(ret)#"
      else
        throw(InvalidStateException)
      end
    end
    ret = "$(ret)\n"
  end

  print(io, "Valley(min $(v.turn)): $(length(v.storms)) storms, $(length(free_spots(v))) free spots.\n$(ret)")
end

function free_spots(v::Valley)
  ret = Set{Position}()
  push!(ret, Position(1,0), Position(v.x,v.y+1))

  for x in 1:v.x
    for y in 1:v.y
      push!(ret, Position(x, y))
    end
  end

  for storm in v.storms
    delete!(ret, storm.position)
  end

  return ret
end