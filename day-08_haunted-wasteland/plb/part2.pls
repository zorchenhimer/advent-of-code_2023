input file
debug file
NodeFile ifile
seq form "-1"

DirectionLen form "307"
DirectionIdx form 3
DirectionList dim 1(307)

temp dim 3
X form 3
Y form 20
StepCount form 20
EndCount form 3

A form 20
B form 20
C form 20

NodeInputRecord list
NodeCurrent dim 3
    dim 4
NodeLeft    dim 3
    dim 2
NodeRight   dim 3
    listend

NodeRecord varlist NodeCurrent,NodeLeft,NodeRight

CurrentNodes dim 9(6)
Counts form 20(6)

IdxNode list
idxSeq dim 2
idxEnd dim 1
    listend

    open input,"../input.txt"
    prep NodeFile,"nodes.txt","nodes.isi","3","9"
    prep debug,"debug.txt"

    read input,seq;DirectionList
    read input,seq;temp

    move "0" to StepCount
    move "1" to X

    loop
        read input,seq;NodeInputRecord
        break if over

        unpack NodeCurrent to IdxNode
        if (idxEnd = "A")
            pack CurrentNodes(X) with NodeRecord
            incr X
        endif

        write NodeFile,NodeCurrent;NodeRecord
    repeat
    close input

    for X from "1" to "6" by "1"
        move "1" to DirectionIdx
        display x," ",CurrentNodes(x)
        move "0" to Counts(x)
        move "0" to Y

        loop
            if (counts(x) == "13200")
what            move y to y
            endif
            move CurrentNodes(x) to Temp
            read NodeFile,Temp;CurrentNodes(x)
            if over
                display "something went wrong"
                stop
            endif

            incr y
            //if (y >= 10000)
            //    display *P10:10,counts(x)
            //    move "0" to Y
            //endif
            unpack CurrentNodes(x) into NodeRecord

            //move NodeCurrent to Temp
            move NodeCurrent to IdxNode

            switch DirectionList(DirectionIdx)
                case "L"
                    move NodeLeft to NodeCurrent
                    //move " - " to NodeRight
                case "R"
                    move NodeRight to NodeCurrent
                    //move " - " to NodeLeft
            endswitch
            pack CurrentNodes(x) with NodeRecord

            incr Counts(x)
            unpack NodeCurrent to IdxNode
            if (idxEnd = "Z")
                break
            endif

            incr DirectionIdx
            if (DirectionIdx > DirectionLen)
                move "1" to DirectionIdx
            endif
        repeat
    repeat

hell
    close NodeFile
    weof debug,seq
    close debug

    for x from "1" to "6" by "1"
        display counts(x)
    repeat

    call lcm giving a using Counts(1),Counts(2)
    call lcm giving b using Counts(3),a

    call lcm giving a using Counts(4),Counts(5)
    call lcm giving c using Counts(6),a

    call lcm giving a using b,c
    display "lcm: ",a

    if (a < "12315788159977")
        display "TOO LOW"
    elseif (a > "12315788159977")
        display "TOO HIGH"
    endif
    stop

lcm function
a form 20
b form 20
    entry
ret form 20
g form 20

    call gcd giving g using a, b
    calc ret = (a * (b / g))
    return using ret

    functionend

gcd function
a form 20
b form 20
    entry
c form 20
//d form 20.10

    loop
        //calc c = b - (a / b)
        calc c = a - (a / b) * b
        move b to a
        move c to b
        while (b <> "0")
    repeat

    //if (a < 0)
    //    calc b = (a * -1)
    //    move b to a
    //endif
    return using a
    functionend
