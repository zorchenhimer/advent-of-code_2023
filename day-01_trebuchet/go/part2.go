package main

import (
	"os"
	"fmt"
	"strings"
)

var words = map[string]int{
	"zero":  0,
	"one":   1,
	"two":   2,
	"three": 3,
	"four":  4,
	"five":  5,
	"six":   6,
	"seven": 7,
	"eight": 8,
	"nine":  9,

	"0": 0,
	"1": 1,
	"2": 2,
	"3": 3,
	"4": 4,
	"5": 5,
	"6": 6,
	"7": 7,
	"8": 8,
	"9": 9,
}

const spaces string = "                                                        "

func main() {
	raw, err := os.ReadFile("../input.txt")
	if err != nil {
		fmt.Println("error reading file:", err)
		return
	}

	lines := strings.Split(strings.ReplaceAll(string(raw), "\r", ""), "\n")

	sum := 0
	for _, line := range lines {
		if line == "" {
			continue
		}

		first, last := 0, 0
		idxFirst, idxLast := 100, -1

		for word, val := range words {
			idx := strings.Index(line, word)
			if idx != -1 && idx < idxFirst {
				first = val
				idxFirst = idx
			}

			idx = strings.LastIndex(line, word)
			if idx == -1 {
				continue
			}

			if idx > idxLast {
				last = val
				idxLast = idx
			}
		}

		sum += (first*10)+last
	}
	fmt.Println(sum)
}
