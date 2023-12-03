input file FIXED=140
debug file
seq form "-1"

line dim 1(140)

X form 3
Y form 3
Z form 3

NumberData list
ndLineIdx form 3
ndColumnIdx form 3
ndLength form 3
ndValue dim 3
    listend

ReadState list
rsLineIdx form 3
rsColumnIdx form 3
    listend

IsPart init "N"
PartValue form 3
RunningSum form 7

LineLength form "140"
LineCount form "140"

    move "0" to ReadState
    move "-1" to rsLineIdx

    open input,"../input.txt"
    prep debug,"debug.txt"

    loop
        move "0" to NumberData
        call GetNextNumber
        break if (ndLength = "0")

        call IsPartNumber
        if (IsPart = "Y")
            move ndValue to PartValue
            add PartValue to RunningSum
        endif

        display ndValue," ",IsPart
        write debug,seq;ndLineidx," ",ndValue," ",IsPart
    repeat

    display "Sum: ",RunningSum

    close input
    weof debug,seq
    close debug
    stop

GetNextNumber
    loop
.       Read a line into the buffer
        if (rsLineIdx = "-1" || rsColumnIdx > LineLength)
            incr rsLineIdx
            if (rsLineIdx = LineCount)
                move "0" to NumberData
                return
            endif

            move "1" to rsColumnIdx
            read input,rsLineIdx;Line
        endif

        loop
            switch line(rsColumnidx)
                case "0" or "1" or "2" or "3" or "4" or:
                     "5" or "6" or "7" or "8" or "9"
                     goto FoundNextNumber
            endswitch

            incr rsColumnIdx
.           Read next line if we run out of line
            goto GetNextNumber if (rsColumnIdx > LineLength)
        repeat
    repeat

FoundNextNumber
    move rsLineIdx to ndLineIdx
    move rsColumnIdx to ndColumnIdx

    loop
        switch line(rsColumnidx)
            case "0" or "1" or "2" or "3" or "4" or:
                 "5" or "6" or "7" or "8" or "9"
            default
                 goto FoundNumberEnd
        endswitch

        incr rsColumnIdx
        break if (rsColumnIdx > LineLength)
    repeat

FoundNumberEnd
    calc ndLength = rsColumnIdx - ndColumnIdx
    clear ndValue
    for X from ndColumnIdx to (rsColumnIdx-1) by "1"
        append line(x) to ndValue
    repeat
    reset ndValue
    return

IsPartNumber
    move "N" to IsPart

.   Look at current line
    if (ndColumnIdx > "1")
        move ndColumnIdx to x
        decr x
        if (line(x) != ".")
            move "Y" to IsPart
            return
        endif
    endif

    add ndColumnIdx to ndLength giving X
    if (x < LineLength)
        if (line(x) != ".")
            move "Y" to IsPart
            return
        endif
    endif

.   Look at prev line
    if (rsLineIdx > "0")
        move rsLineIdx to Y
        decr Y
        call IsPartNumber_CheckLine
        goto IsPartNumberDone if (IsPart = "Y")
    endif

.   Look at next line
    if ((rsLineIdx+1) < Linecount)
        move rsLineIdx to Y
        incr Y
        call IsPartNumber_CheckLine
    endif

IsPartNumberDone
.   Re-read the current line into the buffer for the next number
    read input,rsLineIdx;line
    return

IsPartNumber_CheckLine
        read input,Y;line

.       Make the check further down a bit easier
        for Z from "1" to LineLength by "1"
            replace ". 0 1 2 3 4 5 6 7 8 9 " in line(z)
        repeat

        move ndColumnIdx to Y
        decr Y
        if (Y < "1")
            move "1" to Y
        endif

        add ndColumnIdx to ndLength giving z
        if (z > LineLength)
            move LineLength to Z
        endif

        for x from y to z by "1"
            if (line(x) != " ")
                move "Y" to IsPart
                return
            endif
        repeat
    return
