input file
debug file
seq form "-1"

WinningNumbers dim 3(10)
CardNumbers dim 3(25)

RunningSum form 7
WinCount form 3

WinningCount form "10"
NumberCount form "25"
LineParts list
    dim 5 "Card "
CardNumber form 3
    dim 2 ": "
WinningRaw dim 29
    dim 3 " | "
NumbersRaw dim 74
    listend

X form 3
Y form 3
Found form 3
pow form 4

    open input,"../input.txt"
    prep debug,"debug.txt"

    loop
        read input,seq;LineParts
        break if over
        write debug,seq;"Card ",CardNumber,": ",WinningRaw," | ",NumbersRaw

        unpack WinningRaw into WinningNumbers
        unpack NumbersRaw into CardNumbers

        write debug,seq;"  winning:";
        for x from "1" to WinningCount by "1"
.           Remove spaces in each number.  Things break otherwise.
            squeeze WinningNumbers(x),WinningNumbers(x)
            write debug,seq;*ll," '",WinningNumbers(x),"'";
        repeat
        write debug,seq;""

        write debug,seq;"  Numbers:";
        for x from "1" to NumberCount by "1"
.           Remove spaces in each number.  Things break otherwise.
            squeeze CardNumbers(x),CardNumbers(x)
            write debug,seq;*ll," '",CardNumbers(x),"'";
        repeat
        write debug,seq;""

        write debug,seq;"  found:";
        move "-1" to Found
        for x from "1" to WinningCount by "1"
            for y from "1" to NumberCount by "1"
                if (WinningNumbers(x) = CardNumbers(y))
                    incr found
                    write debug,seq;*ll," ",WinningNumbers(x);
                endif
            repeat
        repeat
        write debug,seq;""

        if (found > "-1")
            power found by "2" giving pow
            add pow to RunningSum
            write debug,seq;"  found:",found," pow: ",pow
        else
            write debug,seq;"  nothing found"
        endif
        incr found
        display "Card: ",CardNumber," found: ",Found," pow: ",pow

    repeat
    close input
    weof debug,seq
    close debug

    display "RunningSum: ",RunningSum
    if (RunningSum > "26218")
        display "TOO HIGH"
    elseif (RunningSum < "26218")
        display "TOO LOW"
    endif

    stop
