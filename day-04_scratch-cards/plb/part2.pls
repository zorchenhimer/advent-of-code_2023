input file
debug file
cardfile ifile
seq form "-1"

CardRec list
CardId dim 3
CardWins form 6
CardCopies form 8
    listend

WinningNumbers dim 3(10)
CardNumbers dim 3(25)

CurrentCard dim 3
RunningSum form 9

WinningCount form "10"
NumberCount form "25"
LineParts list
    dim 5 // "Card "
CardNumber form 3
    dim 2 // ": "
WinningRaw dim 29
    dim 3 // " | "
NumbersRaw dim 74
    listend

A form 7
B form 7
X form 3
Y form 3
Z form 3

Form3 form 3
Found form 3
char dim 3


    open input,"../input.txt"
    prep debug,"debug.txt"

    prep cardfile,"cards.txt","cards.isi","3","17"

.   Pass 1; Find number of wins on each card
    loop
        read input,seq;LineParts
        break if over

        move "0" to found
        move "0" to CardWins

        write debug,seq;"Card ",CardNumber,": ",WinningRaw," | ",NumbersRaw

        unpack WinningRaw into WinningNumbers
        unpack NumbersRaw into CardNumbers

        write debug,seq;"  winning:";
        for x from "1" to WinningCount by "1"
            squeeze WinningNumbers(x),WinningNumbers(x)
            write debug,seq;*ll," '",WinningNumbers(x),"'";
        repeat
        write debug,seq;""

        write debug,seq;"  Numbers:";
        for x from "1" to NumberCount by "1"
            squeeze CardNumbers(x),CardNumbers(x)
            write debug,seq;*ll," '",CardNumbers(x),"'";
        repeat
        write debug,seq;""

        move "0" to found
        for x from "1" to WinningCount by "1"
            for y from "1" to NumberCount by "1"
                if (WinningNumbers(x) = CardNumbers(y))
                    incr found
                endif
            repeat
        repeat
        write debug,seq;"  found: ",found
        write debug,seq;""

        move CardNumber to CardId
        move found to CardWins
        move "1" to CardCopies
        write cardfile,CardId;CardRec

    repeat
    close cardfile
    close input

    weof debug,seq
    close debug

.   Pass 2; Add copies of each card to running sum while calculating
.   subsequent card's copies.
    move "0" to RunningSum
    open cardfile,"cards.isi"
    loop
        readks CardFile;CardRec
        break if over
        add CardCopies to RunningSum
        move CardCopies to A

        display "CardId:",CardId," Wins:",CardWins," Copies:",CardCopies

        move CardId to CurrentCard,Form3
        move CardWins to Z

.       For each copy
        for B from "1" to A by "1"
.           For each win
            for X from "1" to Z by "1"
.               Read card at CardID + X and add increment copies by one.

.               CardID + X = next = Y
                add Form3 to X giving Y
                move Y to char
                read CardFile,char;CardRec
                incr CardCopies
                update Cardfile;CardRec
            repeat
        repeat

.       Re-read the starting card so we continue from the correct place at
.       the top of the outer loop.
        read CardFile,CurrentCard;CardRec
    repeat
    close cardfile

    display "RunningSum: ",RunningSum
    if (RunningSum < "9997537")
        display "TOO LOW"
    elseif (RunningSum > "9997537")
        display "TOO HIGH"
    endif
    stop

