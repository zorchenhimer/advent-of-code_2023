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
	branches := []string{}
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

		if n.Name[2] == 'A' {
			branches = append(branches, n.Name)
		}

		nodes[n.Name] = n
	}

	//fmt.Println("branches:", branches)
	//return

	DirIdx := 0
	//steps := 0
	//endCount := 0
	var CurrentNode string
	multiples := make([]int, len(branches))

	for idx, b := range branches {
		fmt.Println(idx, b)
		x := 0
		for {
			n := nodes[b]

			if b[2] == 'Z' {
				break
			}
			x++

			switch directions[DirIdx] {
			case 'L':
				CurrentNode = n.Left
			case 'R':
				CurrentNode = n.Right
			}

			b = CurrentNode
			DirIdx++
			if DirIdx >= len(directions) {
				DirIdx = 0
			}
		}

		multiples[idx] = x

	}

	fmt.Println("multiples:", multiples)

	//first :=  lcm(multiples[0], multiples[1])
	//second := lcm(multiples[2], multiples[3])
	//third :=  lcm(multiples[4], multiples[5])

	//fourth := lcm(first, second)

	//fifth := lcm(fourth, third)

	a := lcm(multiples[0], lcm(multiples[1], multiples[2]))
	b := lcm(multiples[3], lcm(multiples[4], multiples[5]))
	c := lcm(a, b)

	fmt.Println(c)

	//if steps < 18113 {
	//	fmt.Println("TOO LOW")
	//} else if steps > 18133 {
	//	fmt.Println("TOO HIGH")
	//}
}

/*
	a * b = lcm(a, b) * gcd(a, b). So

	lcm(a, b) = a*b/gcd(a, b)

	0 1
	2 3
	4 5

	01 23

	0123
	45
*/

func lcm(a, b int) int {
	return a * (b / gcd(a, b))
}

func gcd(a, b int) int {
	for b != 0 {
		a, b = b, a%b
	}
	return a
}
