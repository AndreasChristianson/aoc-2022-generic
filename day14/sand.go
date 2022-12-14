package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

type Point struct {
	column int
	depth  int
}

func point(col int, depth int) Point {
	return Point{
		column: col,
		depth:  depth,
	}
}

type State struct {
	material string
}

func wall() State {
	return State{material: "#"}
}
func sand() State {
	return State{material: "O"}
}

func check(e error) {
	if e != nil {
		panic(e)
	}
}

func s(pos Point) Point {
	return point(pos.column, pos.depth+1)
}

func se(pos Point) Point {
	return point(pos.column+1, pos.depth+1)
}
func sw(pos Point) Point {
	return point(pos.column-1, pos.depth+1)
}
func dropSandWithOutFloor(grid map[Point]State, from Point, maxDepth int) bool {
	currPos := from
	for {
		toS := s(currPos)
		toSE := se(currPos)
		toSW := sw(currPos)

		if currPos.depth > maxDepth+1 {
			return false
		} else if _, found := grid[toS]; !found {
			currPos = toS
		} else if _, found := grid[toSW]; !found {
			currPos = toSW
		} else if _, found := grid[toSE]; !found {
			currPos = toSE
		} else {
			grid[currPos] = sand()
			return true
		}
	}
}

func dropSandWithFloor(grid map[Point]State, from Point, maxDepth int) bool {
	currPos := from
	for {
		toS := s(currPos)
		toSE := se(currPos)
		toSW := sw(currPos)

		if currPos.depth == maxDepth+1 {
			grid[currPos] = sand()
			return true
		} else if _, found := grid[toS]; !found {
			currPos = toS
		} else if _, found := grid[toSW]; !found {
			currPos = toSW
		} else if _, found := grid[toSE]; !found {
			currPos = toSE
		} else {
			grid[currPos] = sand()
			if currPos == from {
				return false
			}
			return true
		}
	}
}

func main() {
	lines := getLines("input.txt")
	points := toPoints(lines)
	grid := toGrid(points)
	// grid[point(500, 0)] = State{material: "+"}
	debugGrid(grid)
	maxDepth := 0
	for k := range grid {
		maxDepth = max(maxDepth, k.depth)
	}
	for dropSandWithFloor(grid, point(500, 0), maxDepth) {
	}
	debugGrid(grid)

	sandCount := 0
	for _, v := range grid {
		if v == sand() {
			sandCount++
		}
	}
	fmt.Println(fmt.Sprintf("sand count without floor: %d", sandCount))
}
func getLines(file string) []string {

	//read
	dat, err := os.ReadFile(file)
	check(err)

	//trim empty
	lines := strings.Split(string(dat), "\n")
	i := 0 // output index
	for _, line := range lines {
		if len(line) > 0 {
			lines[i] = line
			i++
		}
	}
	lines = lines[:i]
	//debug
	for index, line := range lines {
		fmt.Println(fmt.Sprintf("%d: |%s|", index, line))
	}
	return lines
}

func toPoints(lines []string) [][]Point {
	points := make([][]Point, len(lines))
	for lineIndex, line := range lines {
		pointStrings := strings.Split(line, " -> ")
		points[lineIndex] = make([]Point, len(pointStrings))
		for pointIndex, pointString := range pointStrings {
			pos := strings.Split(pointString, ",")
			column, err := strconv.Atoi(pos[0])
			check(err)
			depth, err := strconv.Atoi(pos[1])
			check(err)
			points[lineIndex][pointIndex] = Point{
				column: column,
				depth:  depth,
			}
		}
	}

	for _, wall := range points {
		for _, point := range wall {
			fmt.Println(fmt.Sprintf("point: %+v", point))
		}
		fmt.Println()
	}

	return points
}

func toGrid(points [][]Point) map[Point]State {
	grid := make(map[Point]State)
	for _, wall := range points {
		for pointIndex := 0; pointIndex < len(wall)-1; pointIndex++ {
			from := wall[pointIndex]
			to := wall[pointIndex+1]
			fmt.Println(fmt.Sprintf("drawing wall. from: %+v, to %+v", from, to))
			wallBetween(grid, from, to)
		}
	}
	return grid
}

func Sig(x int) int {
	if x < 0 {
		return -1
	}
	return 1
}

func wallBetween(grid map[Point]State, from Point, to Point) {
	if from.column == to.column {
		delta := to.depth - from.depth
		increment := Sig(delta)
		fmt.Println(fmt.Sprintf("depth delta: %d, inc:%d", delta, increment))
		for index := 0; index != delta; index = index + increment {
			point := point(from.column, from.depth+index)
			grid[point] = wall()
		}
	}
	if from.depth == to.depth {
		delta := to.column - from.column
		increment := Sig(delta)
		fmt.Println(fmt.Sprintf("col delta: %d, inc:%d", delta, increment))
		for index := 0; index != delta; index = index + increment {
			point := point(from.column+index, from.depth)
			grid[point] = wall()
		}
	}
	grid[to] = wall()
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}

func debugGrid(grid map[Point]State) {
	var minCol int = 500
	var maxCol int = 500
	var maxDepth int
	for k := range grid {
		minCol = min(minCol, k.column)
		maxCol = max(maxCol, k.column)
		maxDepth = max(maxDepth, k.depth)
	}
	fmt.Println(fmt.Sprintf("minCol: %d, maxCol: %d, depth: %d", minCol, maxCol, maxDepth))
	debug := ""
	for depth := 0; depth <= maxDepth; depth++ {
		for col := minCol; col <= maxCol; col++ {

			if state, found := grid[point(col, depth)]; found {
				debug = debug + state.material

			} else {

				debug = debug + " "
			}
		}
		debug = debug + "\n"

	}
	println(debug)
}
