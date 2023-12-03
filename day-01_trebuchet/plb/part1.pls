input file
line dim 100
char dim 1
seq form "-1"

digits list
firstdigit dim 1
seconddigit dim 1
    listend

LineDigitForm form 2
LineDigitDim dim 2
RunningSum form 8

    display *n,"Starting"
    open input,"../input.txt"

    loop
        read input,seq;line
        break if over

        move 0 to LineDigitForm

.       First digit
        loop
            move " " to char
            cmove line to char
            break if eos

            call IsDigit using char
            if zero
                move char to Digits
                break
            endif
            bump line
            break if eos
        repeat

.       Second digit
        loop
            move " " to char
            cmove line to char
            break if eos

            call IsDigit using char
            if zero
                move char to SecondDigit
            endif
            bump line
            break if eos
        repeat

.       The maths
        pack LineDigitDim with Digits
        move LineDigitDim to LineDigitForm
        display LineDigitForm,"+",RunningSum,"=";
        add LineDigitForm to RunningSum
        display RunningSum
    repeat

    display "Sum: ",RunningSum

    close input
    stop


IsDigit function
inchar dim 1
    entry

    switch inchar
        case "1" or "2" or "3" or "4" or "5" or "6" or "7" or "8" or "9" or "0"
            setflag zero
            return
    endswitch

    setflag not zero
    return

    functionend
