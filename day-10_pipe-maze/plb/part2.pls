//input file fixed=140
//output file fixed=140
//LineLength define 5
//ThreeXLength define 15
LineLength define 140
ThreeXLength define 420

input file fixed=LineLength
output file fixed=LineLength
output2 file fixed=LineLength
LgOutput file fixed=ThreeXLength
seq form "-1"

line dim 1(LineLength)
outline dim 1(LineLength)
lgoutline dim 1(ThreeXLength)

Coord record definition
X form 3    // 1 based
Y form 3    // 0 based
    recordend

StartCoord record like Coord
WorkCoord record like Coord

CoordA record like Coord
CoordB record like Coord
TileCoord record like Coord

From dim 1   // N, S, E, W
Length form 8
A dim 1
B dim 1
AB dim 2
X form 3
Y form 3
Count form 8
Answer form 8
AnswerLine dim 8
EvenOdd init "O"
Swap init "N"

Yes  init "Y"
No   init "N"
Even init "E"
Odd  init "O"

    dim 1(4):
North ("N"):
South ("S"):
East  ("E"):
West  ("W")

    dim 1(8):
NorthSouth ("|"):
EastWest   ("-"):
NorthEast  ("L"):
NorthWest  ("J"):
SouthEast  ("F"):
SouthWest  ("7"):
Ground     ("."):
Start      ("S")
TileType form 1
TileLine dim 1(3)

LargeTiles dim 3(7,3):
// .X.
// .X.
// .X.
LgNorthSouth (" * "),(" * "),(" * "):
// ...
// XXX
// ...
LgEastWest   ("   "),("***"),("   "):
// .X.
// .XX
// ...
LgNorthEast  (" * "),(" **"),("   "):
// .X.
// XX.
// ...
LgNorthWest  (" * "),("** "),("   "):
// ...
// .XX
// .X.
LgSouthEast  ("   "),(" **"),(" * "):
// ...
// XX.
// .X.
LgSouthWest  ("   "),("** "),(" * "):
// ...
// ...
// ...
LgGround     ("   "),("   "),("   ")

    //open input,"../example-input-a.txt"
    //open input,"../example-input-c.txt"
    open input,"../input.txt"
    prep output,"output.txt"

    move " " to line
    for Length from "1" to LineLength by "1"
        write output,seq;line
    repeat
    weof output,seq
    close output

    prep lgoutput,"lgoutput.txt"
    move " " to lgoutline
    for Length from "1" to ThreeXLength by "1"
        write lgoutput,seq;lgoutline
    repeat

    weof lgoutput,seq
    close lgoutput

    open output,"output.txt"
    open lgoutput,"lgoutput.txt"

    move "0" to StartCoord

    // find the start
    loop
        read input,seq;line
        break if over

        for StartCoord.X from "1" to LineLength by "1"
            if (line(StartCoord.X) = "S")
                display StartCoord.X," ",StartCoord.Y
                goto FoundStart
            endif
        repeat
        incr StartCoord.Y
    repeat

FoundStart
    display "Start found at row ",StartCoord.X," and col ",StartCoord.Y
    move StartCoord to WorkCoord
    call FindConnections

    pack AB with A,B
    switch AB
        case "NS" or "SN"
            move NorthSouth to A
            move "1" to TileType
        case "EW" or "WE"
            move EastWest to A
            move "2" to TileType
        case "NW" or "WN"
            move NorthWest to A
            move "4" to TileType
        case "NE" or "EN"
            move NorthEast to A
            move "3" to TileType
        case "SW" or "WS"
            move SouthWest to A
            move "5" to TileType
        case "SE" or "ES"
            move SouthEast to A
            move "6" to TileType
    endswitch

    move " " to outline
    move A to outline(StartCoord.X)
    write output,StartCoord.Y;outline

    calc CoordB.X = ((StartCoord.X * 3)-2)
    calc CoordB.Y = (StartCoord.Y * 3)

    //for Y from CoordB.Y to (CoordB.Y+3) by "1"
    //    move " " to lgoutline
    //    for x from CoordB.X to (CoordB.Y+3) by "1"
    //    repeat

    //    write lgoutput,y;lgoutline
    //repeat

    call WriteLargeTile

    display "first connection:"
    display CoordA.X,CoordA.Y
    read input,CoordA.Y;line
    display line(CoordA.x)," from ",from

    move "1" to Length

    // Now we follow the yellow brick road back to the start
    loop
        read output,CoordA.Y;outline
        move line(CoordA.X) to outline(CoordA.X)
        write output,CoordA.Y;outline

        switch line(CoordA.X)
            case NorthSouth
                move "1" to TileType
            case EastWest
                move "2" to TileType
            case NorthEast
                move "3" to TileType
            case NorthWest
                move "4" to TileType
            case SouthEast
                move "5" to TileType
            case SouthWest
                move "6" to TileType
        endswitch

        calc CoordB.X = ((CoordA.X * 3)-2)
        calc CoordB.Y = (CoordA.Y * 3)
        call WriteLargeTile

        move CoordA to WorkCoord
        switch From
            case West
                switch line(CoordA.X)
                    case EastWest
                        incr CoordA.X
                        move West to From
                    case SouthWest
                        incr CoordA.Y
                        move North to From
                    case NorthWest
                        decr CoordA.Y
                        move South to From
                    default
                        display "[W] huh?"
                        stop
                endswitch

            case East
                switch line(CoordA.X)
                    case EastWest
                        decr CoordA.X
                        move East to From
                    case SouthEast
                        incr CoordA.Y
                        move North to From
                    case NorthEast
                        decr CoordA.Y
                        move South to From
                    default
                        display "[E] huh?"
                        stop
                endswitch

            case North
                switch line(CoordA.X)
                    case NorthSouth
                        incr CoordA.Y
                        move North to From
                    case NorthEast
                        incr CoordA.X
                        move West to From
                    case NorthWest
                        decr CoordA.X
                        move East to From
                    default
                        display "[N] huh?"
                        stop
                endswitch

            case South
                switch line(CoordA.X)
                    case NorthSouth
                        decr CoordA.Y
                        move South to From
                    case SouthEast
                        incr CoordA.X
                        move West to From
                    case SouthWest
                        decr CoordA.X
                        move East to From
                    default
                        display "[S] huh?"
                        stop
                endswitch

            default
                display "From where?"
                stop
        endswitch

        if (CoordA.Y <> WorkCoord.Y)
            read input,CoordA.Y;line
        endif

        incr Length
        // found start again
        if (line(CoordA.X) = Start)
            break
        endif
    repeat

    close input
    close output
    close lgoutput

    open output,"output.txt"
    prep output2,"output2.txt"
    move Odd to EvenOdd

    loop
        read output,seq;outline
        break if over
        move " " to A

        for x from "1" to LineLength by "1"
            move No to Swap
            switch outline(x)
                case NorthSouth
                    move Yes to Swap
                case EastWest
                    move No  to Swap

                case NorthWest
                    if (A = SouthEast)
                        move Yes to Swap
                    endif
                case SouthWest
                    if (A = NorthEast)
                        move Yes to Swap
                    endif

                case NorthEast or SouthEast
                    move outline(x) to a

                default
            endswitch

            if (Swap = Yes)
                if (EvenOdd = Odd)
                    move Even to EvenOdd
                else
                    move Odd to EvenOdd
                endif
            endif

            if (outline(x) = " " && EvenOdd = Even)
                incr Count
                move "x" to outline(x)
            endif
        repeat

        write output2,seq;outline
    repeat
    close output
    weof output2,seq
    close output2

    display "count: ",count

    open input,"../answer.part2.txt"
    read input,seq;AnswerLine
    close input
    move AnswerLine to Answer
    if (count > Answer)
        display "TOO HIGH"
    elseif (count < Answer)
        display "TOO LOW"
    endif

    stop

FindConnections
    // given the row/col center point, find connections
    move WorkCoord to CoordA
    move " " to A,B

    // West
    if (CoordA.X > 1)
        decr CoordA.X
        switch line(CoordA.X)
            case "-" or "F" or "L"
                move East to From,A
        endswitch
        incr CoordA.X
    endif

    // East
    if (CoordA.X < LineLength)
        incr CoordA.X
        switch line(CoordA.X)
            case "-" or "7" or "J"
                move West to From
                if (A = " ")
                    move West to A
                else
                    move West to B
                    return
                endif
        endswitch
        decr CoordA.X
    endif

    // North
    if (CoordA.Y > 1)
        decr CoordA.Y

        read input,CoordA.Y;Line
        switch line(CoordA.X)
            case "|" or "7" or "F"
                move South to From
                if (A = " ")
                    move South to A
                else
                    move South to B
                    return
                endif
        endswitch
        incr CoordA.Y
    endif

    // South
    if (CoordA.Y < LineLength)
        incr CoordA.Y
        read input,CoordA.Y;Line
        switch line(CoordA.X)
            case "|" or "J" or "L"
                move North to From
                move North to B
                return
        endswitch
        decr CoordA.Y
    endif

    display "connection not found!"
    stop

// Expects dest tile's upper left coord in CoordB
WriteLargeTile
    for TileCoord.Y from "1" to "3" by "1"
        move " " to lgoutline
        calc Y = (TileCoord.Y+CoordB.Y)
        unpack LargeTiles(TileType,TileCoord.Y) into TileLine

        read lgoutput,Y;lgoutline
        for TileCoord.X from "1" to "3" by "1"
            calc X = (TileCoord.X+CoordB.X-1)
            move TileLine(TileCoord.X) to lgoutline(x)
        repeat
        write lgoutput,Y;lgoutline
    repeat
    return
