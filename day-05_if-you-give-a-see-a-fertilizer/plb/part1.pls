input file
seq form "-1"
inputfilename dim 100

mapfile ifile
mapkey dim 14

MapValues list
MapType dim 11
MapSeq  form 3
SourceStart form 12
SourceEnd   form 12
Offset      form 12 // offset form source number
    listend

inputline dim 400

//MapSeqForm form 3

InputDest   form 12
InputSource form 12
InputLength form 12

Length form 12

CurrentMapId form 1
MapNames dim 11(7):
    ("soil"),("fertilizer"),("water"),("light"),("temperature"),("humidity"),("location")

Seeds form 12(20)
X form 3
CurrentSeedId form 12
Closest form 12
char dim 1
SeedLimit form 2
EnableSeedLimit init "N"
CurrentSeed form 12

    move S$CMDLIN to char
    if (char = " ")
        bump S$CMDLIN
    endif
    explode S$CMDLIN by " " into InputFilename,SeedLimit

    if (inputfilename = "")
        move "../input.txt" to inputfilename
    endif

    if (SeedLimit > "0")
        move "Y" to EnableSeedLimit
    endif

    //open input,"../example-input.txt"
    //open input,"../input.txt"
    open input,InputFilename
    prep mapfile,"mapfile.txt","mapfile.isi","14","60"

    // throw this out for now (it's the seed numbers)
    read input,seq;inputline
    chop inputline
    bump inputline by 7 // past "seeds: "

    display "seedline: >",*ll,inputline,"<"

    explode inputline by " " into Seeds
    if not zero
        display "explode truncated"
        stop
    endif

    for x from 1 to 20 by 1
        if (Seeds(x) > 0)
            display "seed: ",seeds(x)
        endif
    repeat

    move "0" to CurrentMapId
    loop
        read input,seq;inputline
        break if over
        chop inputline
        continue if (inputline = "")

        scan "map" in inputline
        if equal
            incr CurrentMapId
            fill " " in MapType
            move MapNames(CurrentMapId) to MapType
            setlptr MapType to 11
            move "1" to MapSeq
            continue
        endif

        explode inputline by " " into InputDest,InputSource,InputLength
        move InputSource to SourceStart

        subtract InputSource from InputDest giving Offset
        add InputLength to InputSource giving SourceEnd

        pack MapKey with MapType,MapSeq
        write mapfile,MapKey;MapValues

        display MapKey," Start:",SourceStart," End:",SourceEnd," Offset:",Offset

        incr MapSeq
    repeat
    close input

locloop
    display *n,"Finding locations"
    display "Seed limit:",SeedLimit

.   Foreach seed
    for CurrentSeedId from 1 to 20 by 1
        continue if (Seeds(CurrentSeedId) = 0)
        move Seeds(CurrentSeedId) to CurrentSeed
        display "seed: ",CurrentSeed

.       Foreach range map type
        for CurrentMapId from 1 to 7 by 1
            move "1" to MapSeq

.           Foreach range set
            loop
                fill " " in MapType
                move MapNames(CurrentMapId) to MapType
                setlptr MapType to 11
                pack MapKey with MapType,MapSeq
                read MapFile,MapKey;MapValues
                break if over
                incr MapSeq

                if (CurrentSeed >= SourceStart &:
                    CurrentSeed <= SourceEnd)
                    calc CurrentSeed = (CurrentSeed + Offset)
                    break
                endif
            repeat
            display "  ",MapNames(CurrentMapId)," ",CurrentSeed

        repeat

        //display "Location: ",CurrentSeed,*n
        if (Closest = "0" | Closest > CurrentSeed)
            move CurrentSeed to Closest
        endif

        decr SeedLimit
        if (EnableSeedLimit = "Y" & SeedLimit <= "0")
            display "Seed limit reached"
            break
        endif
    repeat

    display "Closest location: ",Closest
    if (Closest < "278755257")
        display "TOO LOW"
    elseif (Closest > "278755257")
        display "TOO HIGH"
    endif

    close mapfile
    stop
