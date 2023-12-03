package main

import (
	"os"
	"fmt"
	"strings"
)

func main() {
	raw, err := os.ReadFile("../input.txt")
	if err != nil {
		fmt.Println("error reading input:", err)
		return
	}

	lines := strings.Split(strings.ReplaceAll(string(raw), "\r", ""), "\n")

	sum := 0
	for _, line := range lines {
		first, last := 0, 0
		for _, char := range line {
			if char >= 0x30 && char <= 0x39 {
				last = int(char) - 0x30
				if first == 0 {
					first = last
				}
			}
		}
		sum += (first*10)+last
	}

	fmt.Println(sum)
}
