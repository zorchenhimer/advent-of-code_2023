input file
seq form "-1"

Line dim 200
MinRed form 3
MinGreen form 3
MinBlue form 3

RunningSum form 6

LineA dim 1
LineB dim 3
GameNum form 3

Rounds dim 100(6)
Cubes dim 20(3)
X form 3
Y form 3
Z form 3

Number form 3
Color dim 10
Char dim 1
GamePower form 6

    open input,"input.txt"

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
        explode line using ";" into Rounds(1),Rounds(2),Rounds(3):
                                    Rounds(4),Rounds(5),Rounds(6)

.       Inspect each round in game
        move 0 to MinRed,MinGreen,MinBlue
        for x from "1" to "6" by "1"

.           Split groupings
            explode Rounds(X) using "," into Cubes(1),Cubes(2),Cubes(3)
            for Y from "1" to "3" by "1"
                count Z in Cubes(Y)
                continue if (Z = "0")

.               Get rid of leading space if it's there.
                move Cubes(Y) to char
                if (char = " ")
                    bump Cubes(Y)
                endif

.               Get minimums for each color
                explode Cubes(Y) using " " into Number,Color
                if (Color = "red" & MinRed < Number)
                    move Number to MinRed
                elseif (Color = "green" & MinGreen < Number)
                    move Number to MinGreen
                elseif (Color = "blue" & MinBlue < Number)
                    move Number to MinBlue
                endif
            repeat
        repeat

.       The maths
        calc GamePower = MinRed * MinGreen * MinBlue
        add GamePower to RunningSum

    repeat
    close input

    display "Sum: ",RunningSum
    stop
