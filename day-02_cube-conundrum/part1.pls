input file
possibles file
seq form "-1"

Line dim 200
CountRed form 3
CountGreen form 3
CountBlue form 3

RunningSum form 6

LineA dim 1
LineB dim 3
GameNum form 3

Rounds dim 100(5)
X form 3
Y form 3
Possible init "Y"
PossibleCount form 3
Cubes dim 20(3)

Number form 3
Color dim 10
Char dim 1

    open input,"input.txt"
    prep possibles,"possible-games.txt"

    loop
        read input,seq;line
        break if over

.       Grab the game number
        explode line using " " into LineA,LineB
        whereis ":" in LineB giving X
        decr X
        setlptr LineB to X
        move LineB to GameNum

.       Split the game rounds
        explode line using ";" into Rounds(1),Rounds(2),Rounds(3),Rounds(4),Rounds(5)

.       Inspect each round in game
        move "Y" to Possible
        for x from "1" to "5" by "1"

.           Split groupings
            explode Rounds(X) using "," into Cubes(1),Cubes(2),Cubes(3)
            for Y from "1" to "3" by "1"

.               Get rid of leading space if it's there.
                move Cubes(Y) to char
                if (char = " ")
                    bump Cubes(Y)
                endif

.               Split number and color
                explode Cubes(Y) using " " into Number,Color
                if ((Color = "red" & Number > "12") ||:
                    (Color = "green" & Number > "13") ||:
                    (Color = "blue" & Number > "14"))
                    move "N" to Possible
                    break
                endif
            repeat

.           Break early
            break if (possible = "N")
        repeat

        if (Possible = "Y")
            add GameNum to RunningSum
            reset line
            write possibles,seq;*ll,line
            incr PossibleCount
        endif

    repeat
    close input
    weof possibles,seq
    close possibles

    display "Valid games: ",PossibleCount
    display "Sum: ",RunningSum
    stop
