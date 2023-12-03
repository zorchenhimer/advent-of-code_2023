package main

import (
	"os"
	"fmt"
	"strings"
)

func main() {
	raw, err := os.ReadFile("../input.txt")
	if err != nil {
		fmt.Println(err)
		return
	}

	lines := strings.Split(strings.ReplaceAll(string(raw), "\r", ""), "\n")

	sum := 0
	for _, line := range lines {
		if line == "" {
			continue
		}

		gameId := 0
		_, err = fmt.Sscanf(line, "Game %d:", &gameId)
		if err != nil {
			fmt.Println(err)
			return
		}

		idx := strings.Index(line, ":")
		if idx == -1 {
			fmt.Println("colon not found")
			return
		}

		rounds := strings.Split(line[idx+1:], ";")
		red, green, blue := 0, 0, 0
		for _, round := range rounds {
			groups := strings.Split(round, ",")

			for _, group := range groups {
				group = strings.TrimSpace(group)
				var val int
				_, err = fmt.Sscanf(group, "%d red", &val)
				if err == nil && val > red {
					red = val
				}

				_, err = fmt.Sscanf(group, "%d green", &val)
				if err == nil && val > green {
					green = val
				}

				_, err = fmt.Sscanf(group, "%d blue", &val)
				if err == nil && val > blue {
					blue = val
				}
			}
		}

		sum += red * green * blue
	}

	fmt.Println(sum)
}

