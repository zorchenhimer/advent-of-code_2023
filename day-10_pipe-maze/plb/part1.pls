//input file fixed=140
//output file fixed=140
//LineLength define 5
LineLength define 140

input file fixed=LineLength
output file fixed=LineLength
seq form "-1"

line dim 1(LineLength)

Coord record definition
X form 3    // 1 based
Y form 3    // 0 based
    recordend

StartCoord record like Coord
WorkCoord record like Coord

CoordA record like Coord
CoordB record like Coord

From dim 1   // N, S, E, W
Length form 8
Half form 8

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
SouthWest  ("7"):
SouthEast  ("F"):
Ground     ("."):
Start      ("S")

    //open input,"../example-input-a.txt"
    //open input,"../example-input-c.txt"
    open input,"../input.txt"
    //prep output,"output.txt"

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

    display "first connection:"
    display CoordA.X,CoordA.Y
    read input,CoordA.Y;line
    display line(coorda.x)," from ",from

    move "1" to Length

    // Now we follow the yellow brick road back to the start
    loop
        move CoordA to WorkCoord
        switch From
            case West
                display line(CoordA.X)
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

    calc half = (length / 2)
    display "length: ",length,*n,"half: ",half

    stop

FindConnections
    // given the row/col center point, find connections
    move WorkCoord to CoordA

    // West
    if (CoordA.X > 1)
        decr CoordA.X
        switch line(CoordA.X)
            case "-" or "F" or "L"
                move East to From
                return
        endswitch
        incr CoordA.X
    endif

    // East
    if (CoordA.X < LineLength)
        incr CoordA.X
        switch line(CoordA.X)
            case "-" or "7" or "J"
                move West to From
                return
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
                return
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
                return
        endswitch
        decr CoordA.Y
    endif

    display "connection not found!"
    stop

    return
