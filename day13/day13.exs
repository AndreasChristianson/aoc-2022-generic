Code.require_file("module_day13.exs")


{:ok, text} = File.read(if length(System.argv())==0 do  "test.txt" else System.argv() end)
IO.puts(inspect(text))

lines = Enum.filter(String.split(text, "\n"), fn line -> String.length(line) > 0 end)
lines = Enum.map(lines, fn line -> Day13.eval(line) end)

pairs = Enum.chunk_every(lines, 2)
IO.puts(inspect(pairs))
results = Enum.map(pairs, fn pair -> [pair, Day13.consider(pair)] end)
results = Enum.with_index(results)
IO.puts(inspect(results))

sum =
  for {[_, 1], index} <- results, reduce: 0 do
    acc ->
      index + acc + 1
  end

IO.puts(inspect(sum))

sorted = Enum.sort([[[2]], [[6]]] ++ lines, {:asc, Day13})

for {[[2]], index} <- Enum.with_index(sorted) do
  IO.puts("[[2]]: #{index + 1}")
end

for {[[6]], index} <- Enum.with_index(sorted) do
  IO.puts("[[6]]: #{index + 1}")
end
