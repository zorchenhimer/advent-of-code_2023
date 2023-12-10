input file
output file
seq form "-1"

inputline dim 50
inputline2 dim 100

Times form 8(4)
Records form 8(4)

X form 8
Y form 8
char dim 1
number dim 5

RaceId form 8
Distance form 8
Time form 8
Count form 8
RunningTotal form 8
Answer form 8

    open input,"../input.txt"
    prep output,"output.txt"

.   Read in race times
    read input,seq;inputline
    whereis ":" in inputline giving X
    incr x
    reset inputline to x

    for x from "1" to "4" by "1"
.       Find end of current field
        loop
            move inputline to char
            break if (char = " ")
            bump inputline
        repeat

.       Find start of next field
        loop
            move inputline to char
            break if (char <> " ")
            bump inputline
        repeat

.       Move to form var, but the long way
        move inputline to number
        chop number
        move number to Times(X)
        display "Time: ",Times(X)

    repeat

.   Read in race record distances
    read input,seq;inputline
    whereis ":" in inputline giving X
    incr x
    reset inputline to x

    for x from "1" to "4" by "1"
.       Find end of current field
        loop
            move inputline to char
            break if (char = " ")
            bump inputline
        repeat

.       Find start of next field
        loop
            move inputline to char
            break if (char <> " ")
            bump inputline
        repeat

.       Move to form var, but the long way
        move inputline to number
        chop number
        move number to Records(X)
        display "Records: ",Records(X)

    repeat

    close input

    move "1" to RunningTotal
    for RaceId from "1" to "4" by "1"
        move "0" to count
        for x from "1" to Times(RaceId) by "1"
            subtract x from times(RaceId) giving Time
            multiply Time by x giving distance
            if (distance > Records(RaceId))
                incr Count
            endif
        repeat

        continue if (Count = "0")
        display "Race: ",RaceId," Count: ",Count

        multiply count by RunningTotal giving Y
        move Y to RunningTotal

    repeat

    open input,"../answer.part1.txt"
    read input,seq;Number
    close input
    move number to Answer

    if (RunningTotal < Answer)
        display "TOO LOW"
    elseif (RunningTotal > Answer)
        display "TOO HIGH"
    endif

    display RunningTotal
