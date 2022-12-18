open System.Text.RegularExpressions

type Point = { x: int; y: int; z: int; }

let p (x, y, z) =
  {Point.x = x; y = y; z = z; }
let pointFromTuple tuple =
  p tuple
let addPoints left right =
  p (left.x+right.x,  left.y+right.y,  left.z+right.z)

let directions = [p(1,0,0);p(0,1,0);p(0,0,1);p(-1,0,0);p(0,-1,0);p(0,0,-1)]
let explode point = 
  directions |> Seq.map (addPoints point)
let checkSides (grid:Set<Point>) (point:Point) = 
  explode point  
    |> Seq.filter (fun p -> not (grid.Contains p))
    |> Seq.length


let findAdjacentBlanks (grid:Set<Point>) point= 
  explode point
    |> Seq.filter (fun p -> not (grid.Contains p))

let findBlanks (grid:Set<Point>) = 
  grid
    |> Seq.collect (findAdjacentBlanks(grid))

let threshold = 1500
let mutable knownInternal:Set<Point> = Set.empty
let mutable knownExternal:Set<Point> = Set.empty
// 1 inside, 0 outside
let traverse (grid:Set<Point>) (blank:Point) = 
  if knownInternal.Contains(blank) then 0
  elif knownExternal.Contains(blank) then 0
  else 
    let mutable visited:Set<Point> = Set.empty
    let mutable candidates:List<Point> = [blank]
    let mutable external = false

    while not candidates.IsEmpty && not external do 
      let curr = candidates.Head
      candidates <- candidates.Tail
      if not (visited.Contains(curr)) then
        let moreBlanks = 
          findAdjacentBlanks(grid) curr 
            |> Seq.filter (fun p -> not (visited.Contains p))
            |> Seq.toList
        visited <- visited.Add(curr)
        candidates <- List.append candidates moreBlanks
        if visited.Count > threshold then
          external <- true
    if external then
      knownExternal <- Set.union knownExternal visited
      0
    else
      knownInternal <- Set.union knownInternal visited
      visited.Count
    

let markBanks (blanks:Set<Point>, grid:Set<Point>):int = 
  blanks   
    |> Seq.map (traverse(grid)) 
    |> Seq.sum

let slice (grid:Set<Point>, holes:Set<Point>) = 
  let mutable result = ""
  for x in 0 .. 20 do
    result <- sprintf "%sslice x=%d\n" result x
    for y in 0 .. 20 do
      result <- sprintf "%s%d" result (y % 10)
      for z in 0 .. 20 do
        if grid.Contains(p(x,y,z)) then
          result <- sprintf "%s#" result
        elif holes.Contains(p(x,y,z)) then
          result <- sprintf "%sO" result
        else
          result <- sprintf "%s " result
      result <- sprintf "%s\n" result
    result <- sprintf "%s 01234567890123456789\n" result

  printfn "%s" result

[<EntryPoint>]
let main args =
    let readLines filePath =
        (System.IO.File.ReadLines(filePath)
         |> Seq.map (fun s -> s.Trim())
         |> Seq.filter (fun s -> s.Length > 0))

    let rawData = readLines args[0]

    let parse line =
        let pattern = Regex("(\\d+),(\\d+),(\\d+)")
        let matches = pattern.Match line
        pointFromTuple (int matches.Groups[1].Value, int matches.Groups[2].Value, int matches.Groups[3].Value)

    let parsed = rawData |> Seq.map parse

    let grid3d = Set(parsed)
    let sides = 
      grid3d
      |> Seq.map (checkSides grid3d)
      |> Seq.sum 

    let borderPoints = Set(findBlanks grid3d)
    printfn "all blank sides: %d" borderPoints.Count

    let internalBlanks = markBanks(borderPoints, grid3d)

    slice(grid3d, knownInternal)

    printfn "sides: %d" sides
    knownInternal
      |> Seq.map (checkSides knownInternal)
      |> Seq.sum 
      |> printfn "internal sides: %d" 
    0


