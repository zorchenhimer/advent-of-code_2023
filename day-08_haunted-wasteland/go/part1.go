package main

import (
	"fmt"
	"os"
	"strings"
)

type Node struct {
	Name string
	Left string
	Right string
}

func (n Node) String() string {
	return n.Name + " = (" + n.Left + ", " + n.Right + ")"
}

func main() {
	//rawinput, err := os.ReadFile("../example-input-b.txt")
	rawinput, err := os.ReadFile("../input.txt")
	if err != nil {
		fmt.Println(err)
		return
	}

	lines := strings.Split(string(rawinput), "\n")
	directions := strings.TrimSpace(lines[0])
	fmt.Println(directions)

	nodes := make(map[string]Node)
	for _, line := range lines[2:] {
		if line == "" {
			continue
		}

		n := Node{
			Name:  line[0:3],
			Left:  line[7:10],
			Right: line[12:15],
		}
		fmt.Println(n)

		nodes[n.Name] = n
	}

	CurrentNode := "AAA"
	DirIdx := 0
	steps := 0
	for {
		n := nodes[CurrentNode]

		switch directions[DirIdx] {
		case 'L':
			CurrentNode = n.Left
		case 'R':
			CurrentNode = n.Right
		}

		steps++
		DirIdx++
		if DirIdx >= len(directions) {
			DirIdx = 0
		}

		if CurrentNode == "ZZZ" {
			break
		}
	}

	fmt.Println(steps)
	if steps < 18113 {
		fmt.Println("TOO LOW")
	} else if steps > 18133 {
		fmt.Println("TOO HIGH")
	} else {
		fmt.Println("CORRECT")
	}
}
