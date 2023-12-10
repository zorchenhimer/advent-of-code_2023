input file
NodeFile ifile
seq form "-1"

DirectionLen form "307"
DirectionIdx form 3
DirectionList dim 1(307)

temp dim 3
X form 3
Y form 3
StepCount form 7

NodeInputRecord list
NodeCurrent dim 3
    dim 4
NodeLeft    dim 3
    dim 2
NodeRight   dim 3
    listend

NodeRecord varlist NodeCurrent,NodeLeft,NodeRight


    open input,"../input.txt"
    prep NodeFile,"nodes.txt","nodes.isi","3","9"

    read input,seq;DirectionList

    read input,seq;temp

    loop
        read input,seq;NodeInputRecord
        break if over

        write NodeFile,NodeCurrent;NodeRecord
    repeat
    close input

    move "1" to DirectionIdx
    move "AAA" to NodeCurrent
    loop
        read NodeFile,NodeCurrent;NodeRecord
        if over
            display "something went wrong"
            stop
        endif

        if (NodeCurrent = "ZZZ")
            display "end found"
            break
        endif
        move NodeCurrent to Temp

        switch DirectionList(DirectionIdx)
            case "L"
                move NodeLeft to NodeCurrent
                move " - " to NodeRight
            case "R"
                move NodeRight to NodeCurrent
                move " - " to NodeLeft
        endswitch

        display Temp," ",DirectionList(DirectionIdx):
            " ",NodeLeft," ",NodeRight

        incr DirectionIdx
        if (DirectionIdx > DirectionLen)
            move "1" to DirectionIdx
        endif
        incr StepCount
    repeat
    close NodeFile

    display "StepCount: ",StepCount
    if (StepCount < "18113")
        display "TOO LOW"
    elseif (StepCount > "18113")
        display "TOO HIGH"
    endif
    stop
