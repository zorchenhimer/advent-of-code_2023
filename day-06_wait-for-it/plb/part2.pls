input file
seq form "-1"

inputline dim 50

X form 20
number dim 20

Distance form 20
Time form 20
RaceTime form 20
RaceRecord form 20
Count form 20
RunningTotal form 20
Answer form 20

    open input,"../input.txt"

.   Get the race time
    read input,seq;inputline
    whereis ":" in inputline giving X
    incr x
    reset inputline to x

    squeeze inputline,Number
    move number to RaceTime

.   Get the race record distance
    read input,seq;inputline
    whereis ":" in inputline giving X
    incr x
    reset inputline to x

    squeeze inputline,Number
    move number to RaceRecord

    close input

    display "RaceTime:   ",RaceTime
    display "RaceRecord: ",RaceRecord

    move "1" to RunningTotal
    move "0" to count

    for x from "1" to RaceTime by "1"
        subtract x from RaceTime giving Time
        multiply Time by x giving Distance
        if (distance > RaceRecord)
            incr Count
        endif
    repeat

    open input,"../answer.part2.txt"
    read input,seq;Number
    move number to Answer
    close input

    if (Count > Answer)
        display "TOO HIGH"
    elseif (Count < Answer)
        display "TOO LOW"
    endif

    display "Count: ",Count

