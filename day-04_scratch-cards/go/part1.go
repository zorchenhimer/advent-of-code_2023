package main

import (
	"fmt"
	"os"
	"strings"
)

func main() {
	raw, err := os.ReadFile("../input.txt")
	if err != nil {
		fmt.Println(err)
		return
	}

	lines := strings.Split(string(raw), "\n")

	RunningSum := 0
	for _, line := range lines {
		if line == "" {
			continue
		}

		cardid := 0
		_, err := fmt.Sscanf(line, "Card %d:", &cardid)
		if err != nil {
			fmt.Println(err)
			return
		}
		fmt.Println(cardid)

		line = strings.ReplaceAll(line, "  ", " ")
		idxA := strings.Index(line, ":")
		idxB := strings.Index(line, "|")

		if idxA == -1 || idxB == -1 {
			fmt.Println("separators not found")
			return
		}

		needles := strings.Split(line[idxA+2:idxB-1], " ")
		haystack := strings.Split(line[idxB+2:], " ")

		for i := 0; i < len(needles); i++ {
			needles[i] = strings.TrimSpace(needles[i])
		}

		for i := 0; i < len(haystack); i++ {
			haystack[i] = strings.TrimSpace(haystack[i])
		}

		fmt.Printf("  needles: %v\n  haystack: %v\n", needles, haystack)

		found := 0
		foundvals := []string{}
		for _, needle := range needles {
			for _, hay := range haystack {
				if needle == hay {
					found++
					foundvals = append(foundvals, needle)
					break
				}
			}
		}
		fmt.Printf("  found: %d %v\n", found, foundvals)

		val := 0
		if found > 0 {
			val = 1
			for i := 0; i < found-1; i++ {
				val *= 2
			}
		}
		fmt.Printf("  val: %d; found: %d\n", val, found)

		RunningSum += val
	}
	fmt.Println("RunningSum:", RunningSum)
}
