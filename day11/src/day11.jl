module day11

ENV["JULIA_DEBUG"] = all

mutable struct Item
  worry::Int
end

@enum Operator begin
  add
  multiply
end

struct Old
end
struct Operation
  param::Union{Int,Old}
  op::Operator
end

mutable struct Monkey
  index::Int
  items::Vector{Item}
  operation::Operation
  test::Int
  trueTarget::Int
  falseTarget::Int
  inspectionCount::Int
end

Monkey(index, items, operation, test, trueTaget, falseTarget) = Monkey(index, items, operation, test, trueTaget, falseTarget, 0)


function getOp(op::AbstractString)::Operator
  if (cmp(op, "+") == 0)
    return add
  elseif (cmp(op, "*") == 0)
    return multiply
  end
end

function getMonkeyIndex(monkey::Monkey)::Int
  return monkey.index
end

input = readlines("input.txt")

@debug "initial input :\n$(join(input,"\n"))"

monkeys = Vector{Monkey}()


for index = 1:7:length(input)
  monkeyIndex = parse(Int, match(r"Monkey (\d+):", input[index]).captures[1])
  itemsString = match(r"Starting items: (.*)", input[index+1]).captures[1]
  itemsStrings = split(itemsString, ", ")
  itemsInts = map(x -> parse(Int, x), itemsStrings)
  items = map(x -> Item(x), itemsInts)
  op, param = match(r"Operation: new = old ([*+]) (.*)", input[index+2]).captures
  paramIsSelf = cmp(param, "old") == 0
  operation = Operation(paramIsSelf ? Old() : parse(Int, param), getOp(op))
  test = parse(Int, match(r"Test: divisible by (\d+)", input[index+3]).captures[1])
  trueTarget = parse(Int, match(r"If true: throw to monkey (\d+)", input[index+4]).captures[1])
  falseTarget = parse(Int, match(r"If false: throw to monkey (\d+)", input[index+5]).captures[1])

  curr = Monkey(monkeyIndex, items, operation, test, trueTarget, falseTarget)
  push!(monkeys, curr)
end


product = reduce(*, map(x -> x.test, monkeys))
@info("product $(product)")

sort(monkeys, by=getMonkeyIndex)

function runOp(left::Int, right::Int, op::Operator)::Int
  if op == multiply
    return left * right
  elseif op == add
    return left + right
  end
end

function inspect(monkey::Monkey, item::Item)
  monkey.inspectionCount = monkey.inspectionCount + 1

  if monkey.operation.param isa Old
    item.worry = runOp(item.worry, item.worry, monkey.operation.op)
  else
    item.worry = runOp(item.worry, monkey.operation.param, monkey.operation.op)
  end
  item.worry = item.worry ÷ 3
end

function dontWorry(monkey::Monkey, item::Item)
  monkey.inspectionCount = monkey.inspectionCount + 1

  if monkey.operation.param isa Old
    item.worry = runOp(item.worry, item.worry, monkey.operation.op)
  else
    item.worry = runOp(item.worry, monkey.operation.param, monkey.operation.op)
  end
  item.worry = item.worry % product
end
function evaluate(monkey::Monkey, item::Item)
  if item.worry % monkey.test == 0
    return monkey.trueTarget
  else
    return monkey.falseTarget
  end
end

for round = 1:10000
  for index = 1:length(monkeys)
    monkey = monkeys[index]
    # @debug "monkey $(index): $(monkey)"
    while !isempty(monkey.items)
      item = popfirst!(monkey.items)
      # @debug "pre-inspection: $(item.worry)"
      dontWorry(monkey, item)
      # @debug "post-inspection: $(item.worry)"
      newMonkey = evaluate(monkey, item)
      # @debug "throwing to monkey $(newMonkey)"
      push!(monkeys[newMonkey+1].items, item)
    end
  end
  if round % 1000 == 0 || round == 20  || round == 1
    @debug "after round $(round)"
    for index = 1:length(monkeys)
      @info "monkey $(index): $(monkeys[index].inspectionCount)"
    end
  end
end

function getInspectionCount(monkey::Monkey)::Int
  return monkey.inspectionCount
end
mostActive = sort(monkeys, by=getInspectionCount)

@warn "monkey business: $(mostActive[end].inspectionCount*mostActive[end-1].inspectionCount)"

end # module day11
