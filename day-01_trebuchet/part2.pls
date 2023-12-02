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

WordIndex form 3
WordValue dim 1
X form 3
Y form 3

numbers dim 10(20):
    ("1"),("2"),("3"),("4"),("5"),("6"),("7"),("8"),("9"),("0"):
    ("one"),("two"),("three"),("four"),("five"),("six"):
    ("seven"),("eight"),("nine"),("zero")

    display *n,"Starting"
    open input,"input.txt"

    loop
        read input,seq;line
        break if over

.       Find first number
        move "100" to WordIndex
        for x from "1" to "20" by "1"
            whereis numbers(x) in line giving Y
            continue if zero
            if (Y < WordIndex)
                move Y to WordIndex
                call DigitValue giving WordValue using numbers(x)
            endif
        repeat
        move WordValue to Digits

.       Find last number
        move "0" to WordIndex
        for x from "1" to "20" by "1"
            whereislast numbers(x) in line giving Y
            continue if zero
            if (Y > WordIndex)
                move Y to WordIndex
                call DigitValue giving WordValue using numbers(x)
            endif
        repeat
        move WordValue to SecondDigit

.       The maths
        pack LineDigitDim with Digits
        move LineDigitDim to LineDigitForm
        display LineDigitForm,"+",RunningSum,"=";
        add LineDigitForm to RunningSum
        display RunningSum
    repeat

    close input
    display "Sum: ",RunningSum
    stop

DigitValue function
WordValue dim 10
    entry

    switch WordValue
        case "one" or "1"
            return using "1"
        case "two" or "2"
            return using "2"
        case "three" or "3"
            return using "3"
        case "four" or "4"
            return using "4"
        case "five" or "5"
            return using "5"
        case "six" or "6"
            return using "6"
        case "seven" or "7"
            return using "7"
        case "eight" or "8"
            return using "8"
        case "nine" or "9"
            return using "9"
        case "zero" or "0"
            return using "0"
    endswitch

    return using " "
    functionend
