input file FIXED=140
debug file
seq form "-1"

LineLength form "140"
LineCount form "140"

line dim 1(140)

X form 3
Y form 3
Z form 3

ReadState list
rsLineIdx form 3
rsColumnIdx form 3
    listend

IsGear init "N"
GearValue form 7

Ratios list
RatioA form 3
RatioB form 3
    listend

NumberTmp dim 3

StartIdx form 3
RunningSum form 15

LoopCount form 7
ThirdFound init "N"

    move "0" to ReadState
    move "0" to LoopCount
    move "-1" to rsLineIdx

    open input,"../input.txt"
    prep debug,"debug.txt"

    loop
        write debug,seq;LoopCount," ",rsLineIdx
        call GetNextGear
        break if (GearValue = 0)
        display LoopCount," ",rsLineIdx," ",GearValue
        add GearValue to RunningSum
        incr LoopCount
    repeat

    display "Sum: ",RunningSum
    if (RunningSum <> "81709807")
        display "YOU BROKE IT"
    endif

    close input
    weof debug,seq
    close debug
    stop

GetNextGear
    loop
.       Read a line into the buffer
        if (rsLineIdx = "-1" || rsColumnIdx > LineLength)
            incr rsLineIdx
            if (rsLineIdx = LineCount)
                write debug,seq;"rsLineIdx = LineCount"
                move "0" to GearValue
                return
            endif

            move "1" to rsColumnIdx
            read input,rsLineIdx;Line
            if over
                write debug,seq;"read OVER"
                move "0" to GearValue
                return
            endif
        endif

.       Find a gear
        loop
            if (line(rsColumnIdx) = "*")
                call GetGearValues
                if (RatioA <> "0" & RatioB <> "0")
                    multiply RatioA by RatioB giving GearValue
                    write debug,seq;" ",RatioA,"x",RatioB,"=",GearValue
                    incr rsColumnIdx
                    return
                endif
            endif
            incr rsColumnIdx

.           Move on to next line
            break if (rsColumnIdx > LineLength)
        repeat
    repeat
    return

. Return the ratios for the Gear.  Clears out ratios if a third is found.
GetGearValues
    move "0" to GearValue
    move "0" to Ratios

.   Check current line
    call GetNumbers
    goto GetValuesTooMany if (ThirdFound = "Y")

.   Check line above
    subtract "1" from rsLineIdx giving Y
    if (Y >= "0")
        read input,Y;line

        call GetNumbers
        goto GetValuesTooMany if (ThirdFound = "Y")
    endif

.   Line below
    add "1" to rsLineidx giving Y
    if (Y < LineCount)
        read input,Y;line
        call GetNumbers
        goto GetValuesTooMany if (ThirdFound = "Y")
    endif

GetValuesDone
.   Re-read current line
    read input,rsLineIdx;line
    return

GetValuesTooMany
    write debug,seq;"too many values; RatioA:",ratioA," RatioB:",RatioB," Third:",GearValue
    move 0 to Ratios
    goto GetValuesDone

GetNumbers
.   Center column
    move rsColumnIdx to Z
    switch line(Z)
        case "0" or "1" or "2" or "3" or "4" or:
             "5" or "6" or "7" or "8" or "9"

.           If we find one in the middle, two other numbers cannot
.           exist on the sides.
            goto GetWholeNumber
    endswitch

.   Left column
    subtract "1" from rsColumnIdx giving Z
    if (Z >= "1")
        switch line(Z)
            case "0" or "1" or "2" or "3" or "4" or:
                 "5" or "6" or "7" or "8" or "9"

                call GetWholeNumber
                return if (ThirdFound = "Y")
        endswitch
    endif

.   Right column
    add "1" to rsColumnIdx giving Z
    if (Z <= LineLength)
        switch line(Z)
            case "0" or "1" or "2" or "3" or "4" or:
                 "5" or "6" or "7" or "8" or "9"

                call GetWholeNumber
                return if (ThirdFound = "Y")
        endswitch
    endif

    return

GetWholeNumber
.   Find start of the number
    for X from Z to "1" by "-1"
        switch line(x)
            case "0" or "1" or "2" or "3" or "4" or:
                 "5" or "6" or "7" or "8" or "9"
            default
                goto FoundNumberStart
        endswitch
    repeat

FoundNumberStart
.   Find the end of the number
    add "1" to x giving StartIdx
    clear NumberTmp
    for X from StartIdx to LineLength by "1"
        switch line(x)
            case "0" or "1" or "2" or "3" or "4" or:
                 "5" or "6" or "7" or "8" or "9"
                 append line(x) to NumberTmp
            default
                goto FoundNumberEnd
        endswitch
    repeat

FoundNumberEnd
    reset NumberTmp
    move NumberTmp to GearValue
    move "N" to ThirdFound
    if (RatioA = "0")
        move NumberTmp to RatioA
    elseif (RatioB = "0")
        move NumberTmp to RatioB
    else
        move "Y" to ThirdFound
    endif
    return
