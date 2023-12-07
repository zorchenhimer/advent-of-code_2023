package main

import (
	"fmt"
	"os"
	"strings"
	"strconv"
)

type RangeOffset struct {
	Start int64
	End int64
	Offset int64
}

func (o RangeOffset) String() string {
	return fmt.Sprintf("Start: %12d End: %12d Offset: %12d",
		o.Start, o.End, o.Offset)
}

var mapTypes = []string{
	"soil",
	"fertilizer",
	"water",
	"light",
	"temperature",
	"humidity",
	"location",
}

func main() {
	//raw, err := os.ReadFile("../example-input.txt")
	raw, err := os.ReadFile("../input.txt")
	if err != nil {
		fmt.Println(err)
		return
	}

	lines := strings.Split(string(raw), "\n")
	idx := strings.Index(lines[0], ":")
	seedstr := strings.Split(lines[0][idx+2:], " ")

	seeds := []int64{}
	for _, str := range seedstr {
		v, err := strconv.ParseInt(str, 10, 64)
		if err != nil {
			fmt.Println(err)
			return
		}

		seeds = append(seeds, v)
	}

	maptypeidx := -1
	offsets := make(map[string][]RangeOffset)
	for _, line := range lines[1:] {
		line = strings.TrimSpace(line)
		if line == "" { continue }

		if strings.Contains(line, "map:") {
			maptypeidx++
			continue
		}

		strvals := strings.Split(line, " ")
		vals := []int64{}
		for _, str := range strvals {
			v, err := strconv.ParseInt(str, 10, 64)
			if err != nil {
				fmt.Println(err)
				return
			}

			vals = append(vals, v)
		}

		offset := RangeOffset{
			Start: vals[1],
			End: vals[1] + vals[2],
			Offset: vals[0] - vals[1],
		}
		offsets[mapTypes[maptypeidx]] = append(offsets[mapTypes[maptypeidx]], offset)
	}

	for _, maptype := range mapTypes {
		fmt.Println(maptype)
		for _, off := range offsets[maptype] {
			fmt.Println(" ", off)
		}
	}
	fmt.Printf("\nSeeds: %v\n", seeds)

	lowest := int64(0)
	for _, seed := range seeds {
		fmt.Printf("\n%-12d\n", seed)
		for _, maptype := range mapTypes {
			for _, off := range offsets[maptype] {
				if off.Start <= seed && seed <= off.End {
					seed += off.Offset
					break
				}
			}
			fmt.Printf("  %-11s %12d\n", maptype, seed)
		}
		if lowest == 0 || seed < lowest {
			lowest = seed
		}
	}
	fmt.Printf("lowest: %12d\n", lowest)
}
