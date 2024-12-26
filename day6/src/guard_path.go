package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
)

// Direction represents the possible directions of guard travel.
type Direction int

const (
	Up Direction = iota
	Right
	Down
	Left
)

// Read the grid.txt fiel into an array of strings
func readGuardPath(fileName string) []string {
	file, err := os.Open(fileName)
	if err != nil {
		log.Fatalf("failed to open file: %s", err)
	}
	defer file.Close()

	var lines []string
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}

	if err := scanner.Err(); err != nil {
		log.Fatalf("failed to read file: %s", err)
	}

	return lines
}

func findStaringPoint(matrix [][]rune) (int, int) {
	var startX, startY int
	found := false
	for i, row := range matrix {
		for j, char := range row {
			if char == '^' {
				startX, startY = i, j
				found = true
				break
			}
		}
		if found {
			break
		}
	}
	return startX, startY
}

func turn(direction Direction) Direction {
	if direction == Left {
		return Up
	} else {
		return direction + 1
	}
}

func walkPath(matrix [][]rune, startX, startY int) (int, bool) {
	direction := Up
	visited := make(map[[2]int]Direction)
	isLoop := false
	x, y := startX, startY
	visited[[2]int{x, y}] = direction
	for {
		if direction == Up {
			x--
		} else if direction == Right {
			y++
		} else if direction == Down {
			x++
		} else if direction == Left {
			y--
		}

		if (x == 0 || y == 0 || x == len(matrix)-1 || y == len(matrix[0])-1) && matrix[x][y] != '#' {
			visited[[2]int{x, y}] = direction
			break
		}

		// Exit out if we've hit a loop
		if prevDirection, ok := visited[[2]int{x, y}]; ok && prevDirection == direction {
			fmt.Printf("By George, we've hit a loop at (%d, %d)\n", x, y)
			isLoop = true
			break
		}

		if matrix[x][y] == '#' {
			// Undo the move and turn
			if direction == Up {
				x++
			} else if direction == Right {
				y--
			} else if direction == Down {
				x--
			} else if direction == Left {
				y++
			}

			direction = turn(direction)
			// fmt.Printf("Turning to %v\n", direction)
			continue
		}

		// Add the coordinates to a set that will only include distinct pairs
		visited[[2]int{x, y}] = direction
	}
	return len(visited), isLoop
}

func main() {
	lines := readGuardPath("grid.txt")
	matrix := make([][]rune, len(lines))
	for i, line := range lines {
		matrix[i] = []rune(line)
	}
	startX, startY := findStaringPoint(matrix)
	fmt.Printf("Initial coordinates of '^' are: (%d, %d)\n", startX, startY)
	numSteps, isLoop := walkPath(matrix, startX, startY)
	fmt.Printf("Number of steps taken by the guard: %d\n", numSteps)
	fmt.Printf("Is there a loop in the path? %t\n", isLoop)

	loopCount := 0
	for i := range matrix {
		for j := range matrix[i] {
			if matrix[i][j] != '#' {
				original := matrix[i][j]
				matrix[i][j] = '#'
				_, isLoop := walkPath(matrix, startX, startY)
				if isLoop {
					loopCount++
				}
				matrix[i][j] = original
			}
		}
	}
	fmt.Printf("Number of loops detected: %d\n", loopCount)
}
