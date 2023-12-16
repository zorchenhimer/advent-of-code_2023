
.include "nes2header.inc"
nes2mapper 0
nes2prg 2 * 16 * 1024
nes2chr 1 * 8 * 1024
;nes2wram 1 * 8 * 1024
nes2mirror 'V'
nes2tv 'N'
nes2end

.feature leading_dot_in_identifiers
.feature underline_in_numbers
.feature addrsize

MENU_LOC = $210C
MENU_ROW_OFFSET = 2 * 32
MENU_CURSOR_START_X = 80
MENU_CURSOR_START_Y = 63
MENU_CURSOR_SPRITE = $02

INPUT_TEST_LOC = $20A4

; Button Constants
BUTTON_A        = 1 << 7
BUTTON_B        = 1 << 6
BUTTON_SELECT   = 1 << 5
BUTTON_START    = 1 << 4
BUTTON_UP       = 1 << 3
BUTTON_DOWN     = 1 << 2
BUTTON_LEFT     = 1 << 1
BUTTON_RIGHT    = 1 << 0

SPRITE_L_ID = $0E
SPRITE_R_ID = $0F

.segment "ZEROPAGE"
Sleeping: .res 1
AddressPointer1: .res 2
AddressPointer2: .res 2

CurrentLineVerify: .res 2
CurrentValueVerify: .res 2
LoadAddress: .res 2

TmpX: .res 1
TmpY: .res 1
Controller: .res 1
Controller_Old: .res 1

MenuSelection: .res 1

InputSize: .res 1
InputLine: .res 60

BufferDest:  .res 2
BufferedLen: .res 1
BufferedTiles: .res 32

Part1_FirstIdx: .res 1
Part1_LastIdx: .res 1

; BCD Sum
RunningSum: .res 5

BinNumber: .res 2
AsciiNumber: .res 5

.segment "OAM"
CursorSprite: .res 4

InspectorSpriteAL: .res 4
InspectorSpriteAR: .res 4

InspectorSpriteBL: .res 4
InspectorSpriteBR: .res 4

.segment "BSS"

.segment "VECTORS0"
    .word NMI
    .word RESET
    .word IRQ

.segment "CHR0"
    .incbin "font.chr"

.segment "CHR1"

.segment "PAGE0"

IRQ:
    rti

NMI:
    pha
    txa
    pha
    tya
    pha

    lda #$FF
    sta Sleeping

    lda #$00
    sta $2003
    lda #$02
    sta $4014

    ldx BufferedLen
    beq @bufferDone
    ldy #0

    lda BufferDest+1
    sta $2006
    lda BufferDest+0
    sta $2006

@bufferLoop:
    lda BufferedTiles, y
    sta $2007
    iny
    dex
    bne @bufferLoop

@bufferDone:

    lda #0
    sta BufferedLen
    sta $2005
    sta $2005

    lda #%1000_0000
    sta $2000

    pla
    tay
    pla
    tax
    pla
    rti

RESET:
    sei         ; Disable IRQs
    cld         ; Disable decimal mode

    ldx #$40
    stx $4017   ; Disable APU frame IRQ

    ldx #$FF
    txs         ; Setup new stack

    inx         ; Now X = 0

    stx $2000   ; disable NMI
    stx $2001   ; disable rendering
    stx $4010   ; disable DMC IRQs

:   ; First wait for VBlank to make sure PPU is ready.
    bit $2002   ; test this bit with ACC
    bpl :- ; Branch on result plus

:   ; Clear RAM
    lda #$00
    sta $0000, x
    sta $0100, x
    sta $0200, x
    sta $0300, x
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x

    inx
    bne :-  ; loop if != 0

:   ; Second wait for vblank.  PPU is ready after this
    bit $2002
    bpl :-

    ; Clear sprites
    ldx #0
    lda #$FF
:
    sta $200, x
    inx
    bne :-

    lda #$00
    sta $2003
    lda #$02
    sta $4014


    lda #$20
    sta $2006
    lda #$00
    sta $2006

    ldy #0
    ldx #4
    lda #0
:
    sta $2007
    dey
    bne :-
    dex
    bne :-

    ; palettes
    lda #$3F
    sta $2006
    lda #$00
    sta $2006

    ldx #32
    ldy #0
:
    lda PaletteData, y
    sta $2007
    iny
    dex
    bne :-

    lda #%1000_0000
    sta $2000

    jsr WaitForNMI
    jsr WaitForNMI

    lda #%0001_1110
    sta $2001

Menu:

    lda #MENU_CURSOR_START_Y
    sta CursorSprite+0

    lda #MENU_CURSOR_SPRITE
    sta CursorSprite+1

    lda #0
    sta CursorSprite+2

    lda #MENU_CURSOR_START_X
    sta CursorSprite+3

    lda #.hibyte(MENU_LOC)
    sta AddressPointer2+1
    lda #.lobyte(MENU_LOC)
    sta AddressPointer2+0

    ldx #0
@menuLoop:
    txa
    asl a
    tay
    lda MenuItems+0, y
    sta AddressPointer1+0
    lda MenuItems+1, y
    sta AddressPointer1+1

    lda AddressPointer2+1
    sta $2006
    lda AddressPointer2+0
    sta $2006

    ldy #$FF
@itemloop:
    iny
    lda (AddressPointer1), y
    beq @next
    sta $2007
    jmp @itemloop

@next:
    inx
    cpx #MenuLength
    beq @done

    clc
    lda AddressPointer2+0
    adc #64
    sta AddressPointer2+0
    lda AddressPointer2+1
    adc #0
    sta AddressPointer2+1
    jmp @menuLoop

@done:

    lda #0
    sta $2005
    sta $2005

    lda #%0001_1110
    sta $2001

    jsr WaitForNMI

    lda #0
    sta MenuSelection

MenuFrame:
    jsr ReadControllers

    lda #BUTTON_UP
    jsr ButtonPressed
    beq :+
    dec MenuSelection
    bpl :+
    lda #MenuLength
    sta MenuSelection
    dec MenuSelection
:

    lda #BUTTON_DOWN
    jsr ButtonPressed
    beq :+
    inc MenuSelection
    lda MenuSelection
    cmp #MenuLength
    bne :+
    lda #0
    sta MenuSelection
:

    lda #BUTTON_A
    jsr ButtonPressed
    beq :+
    jmp MenuAction
:
    lda #BUTTON_START
    jsr ButtonPressed
    beq :+
    jmp MenuAction
:


    ldx MenuSelection
    lda MenuCursorLocations, x
    sta CursorSprite+0

    jsr WaitForNMI

    jmp MenuFrame

MenuAction:
    lda MenuSelection
    asl a
    tax
    lda MenuActions+0, x
    sta AddressPointer1+0
    lda MenuActions+1, x
    sta AddressPointer1+1

    lda #$FF
    .repeat 4, i
    sta CursorSprite+i
    .endrepeat

    jsr WaitForNMI

    lda #0
    sta $2001

    jsr ClearScreen

    jmp (AddressPointer1)

MenuItems:
    .word :+
    .word :++
    MenuLength = (* - MenuItems) / 2

MenuText:
:   .asciiz "Part 1"
:   .asciiz "Part 2"

MenuCursorLocations:
    .repeat MenuLength, i
    .byte (MENU_CURSOR_START_Y + (i * 16))
    .endrepeat

MenuActions:
    .word Part1
    .word Part2

HeaderText:
    .asciiz "Press Start"

Part1:
    lda #$20
    sta $2006
    lda #$4A
    sta $2006

    ldx #0
:
    lda HeaderText, x
    beq :+
    inx
    sta $2007
    jmp :-
:

    jsr WaitForNMI
    lda #%0001_1110
    sta $2001

Part1_Waiting:
    jsr ReadControllers

    lda #BUTTON_START
    jsr ButtonPressed
    beq :+
    jmp Part1_Start
:

    jsr WaitForNMI
    jmp Part1_Waiting

Part1_Start:
    lda #.lobyte(InputData)
    sta LoadAddress+0
    lda #.hibyte(InputData)
    sta LoadAddress+1

    lda #.lobyte(VerifyData)
    sta CurrentLineVerify+0
    lda #.hibyte(VerifyData)
    sta CurrentLineVerify+1

    ; clear out "Press Start"
    ldx #11
    stx BufferedLen
    lda #$20
    sta BufferDest+1
    lda #$4a
    sta BufferDest+0

    lda #0
    ldy #0
:
    sta BufferedTiles, y
    iny
    dex
    bne :-

    ; setup sprite overlays
    lda #SPRITE_L_ID
    sta InspectorSpriteAL+1
    sta InspectorSpriteBL+1

    lda #SPRITE_R_ID
    sta InspectorSpriteAR+1
    sta InspectorSpriteBR+1

    lda #$01
    sta InspectorSpriteAL+2
    sta InspectorSpriteAR+2

    lda #$82
    sta InspectorSpriteBL+2
    sta InspectorSpriteBR+2

    jsr WaitForNMI

; write text
    ; start position
    lda #$21
    sta BufferDest+1
    lda #$C4
    sta BufferDest+0

    lda #0
    sta TmpY
    lda #4  ; total text lines
    sta TmpX

@lineLoop:
    lda TmpY
    inc TmpY

    asl a
    tax
    lda Part1_TextValues+0, x
    sta AddressPointer1+0
    lda Part1_TextValues+1, x
    sta AddressPointer1+1

    ldy #0
@textLoop:
    lda (AddressPointer1), y
    beq :+
    sta BufferedTiles, y
    iny
    jmp @textLoop
:

    sty BufferedLen
    jsr WaitForNMI

    clc
    lda BufferDest+0
    adc #64
    sta BufferDest+0

    lda BufferDest+1
    adc #0
    sta BufferDest+1

    dec TmpX
    bne @lineLoop
    jsr WaitForNMI

    ; Setup RunningSum BCD variable
    lda #0
    ldx #0
:
    sta RunningSum, x
    inx
    cpx #5
    bne :-

    ; Running Value
    jsr Part1_BufferRunning
    jsr WaitForNMI

Part1_Run:
    lda #$FF
    sta InspectorSpriteAL+0
    sta InspectorSpriteAR+0

    sta InspectorSpriteBL+0
    sta InspectorSpriteBR+0

    jsr ReadLine
    lda InputSize
    bne :+
    jmp Part1_Done
:

    sta TmpX
    jsr BufferLine1
    jsr WaitForNMI

    jsr BufferLine2
    jsr WaitForNMI

    jsr BufferLine3
    jsr WaitForNMI

    ; clear out last input's values
    lda #$20
    sta BufferedTiles+0
    sta BufferedTiles+1

    ; first val
    lda #$21
    sta BufferDest+1
    lda #$D7
    sta BufferDest+0
    lda #1
    sta BufferedLen
    jsr WaitForNMI

    ; second val
    lda #$22
    sta BufferDest+1
    lda #$17
    sta BufferDest+0
    lda #1
    sta BufferedLen
    jsr WaitForNMI

    ; combined val
    lda #$22
    sta BufferDest+1
    lda #$56
    sta BufferDest+0
    lda #2
    sta BufferedLen
    jsr WaitForNMI

    ; Find first number
    lda #0
    sta TmpX

    lda InputSize
    sta TmpY

@loopFirst:
    lda TmpX
    inc TmpX
    tay
    tax

    lda #0
    jsr SetInspectorSprite

    lda InputLine, X
    cmp #'0'
    bcc :+

    cmp #':'
    bcs :+

    ;found
    jmp @foundFirst

:   jsr WaitForNMI
    dec TmpY
    bne @loopFirst

@foundFirst:
    stx Part1_FirstIdx

    lda #$21
    sta BufferDest+1
    lda #$D7
    sta BufferDest+0
    lda InputLine, x
    sta BufferedTiles+0
    lda #1
    sta BufferedLen

    jsr WaitForNMI

    ; Find last number
    lda InputSize
    sta TmpX
    dec TmpX
    sta TmpY

@loopSecond:
    lda TmpX
    dec TmpX
    tay
    tax

    lda #1
    jsr SetInspectorSprite

    lda InputLine, X
    cmp #'0'
    bcc :+

    cmp #':'
    bcs :+

    ;found
    jmp @foundSecond

:   jsr WaitForNMI
    dec TmpY
    bpl @loopSecond

@foundSecond:
    stx Part1_LastIdx
    inx
    iny
    lda #1
    jsr SetInspectorSprite
    dex
    dey

    lda #$22
    sta BufferDest+1
    lda #$17
    sta BufferDest+0
    lda InputLine, x
    sta BufferedTiles+0
    lda #1
    sta BufferedLen

    jsr WaitForNMI

    ldx Part1_FirstIdx
    ldy Part1_LastIdx

    lda InputLine, x
    sta BufferedTiles+0
    and #$0F
    tax
    lda Mult10, x
    sta TmpX

    lda InputLine, y
    cmp #'0'
    bcc badval

    cmp #':'
    bcs badval
    jmp :+
badval:
    nop
:
    sta BufferedTiles+1
    and #$0F
    adc TmpX
    sta TmpX

    lda #2
    sta BufferedLen

    lda #$22
    sta BufferDest+1
    lda #$56
    sta BufferDest+0

    jsr WaitForNMI

    ;jsr Part1_AddValue
    ;jsr Part1_BufferRunning
    ;jsr WaitForNMI

AsciiDbg:
    ldx Part1_LastIdx
    lda InputLine, x
    and #$0F
    clc
    adc BinNumber+0
    bcc :+
    inc BinNumber+1
:
    sta BinNumber+0

    ldx Part1_FirstIdx
    lda InputLine, x
    and #$0F
    tax
    lda Mult10, x
    clc
    adc BinNumber+0
    sta BinNumber+0
    bcc :+
    inc BinNumber+1
:
    jsr BinToAscii

    ldx #0
:
    lda AsciiNumber, x
    sta BufferedTiles, x
    inx
    cpx #5
    bne :-

    lda #5
    sta BufferedLen

    lda #$22
    sta BufferDest+1
    lda #$B3
    sta BufferDest+0
    ;lda #$22
    ;sta BufferDest+1
    ;lda #$D3
    ;sta BufferDest+0
    jsr WaitForNMI

;@framewait:
;    jsr ReadControllers
;
;    lda #BUTTON_A
;    jsr ButtonPressed
;    beq :+
;    jmp :++
;:
;    jsr WaitForNMI
;    jmp @framewait
;:
;
;    jsr WaitForNMI
    jmp Part1_Run

Part1_Done:
    jmp Part1_Done

Part2:
    jmp Part2

ReadLine:
    ldy #0
@loop:
    lda (LoadAddress), y
    beq @done
    cmp #$0A
    beq @done
    sta InputLine, y
    iny
    jmp @loop

@done:
    sty InputSize
    iny ; past $0A

    clc
    tya
    adc LoadAddress+0
    sta LoadAddress+0
    lda LoadAddress+1
    adc #0
    sta LoadAddress+1
    rts

BufferLine1:
    lda #.hibyte(INPUT_TEST_LOC)
    sta BufferDest+1
    lda #.lobyte(INPUT_TEST_LOC)
    sta BufferDest+0

    ldy #0
    ldx #24
    stx BufferedLen
:
    lda InputLine, y
    sta BufferedTiles, y
    iny
    ;inc BufferedLen
    dec TmpX
    beq @done
    dex
    bne :-
    rts

@done:
    lda #0
:
    sta BufferedTiles, y
    iny
    dex
    bne :-
    rts

BufferLine2:
    ldy #0
    ldx #24
    stx BufferedLen

    lda #.hibyte(INPUT_TEST_LOC+32)
    sta BufferDest+1
    lda #.lobyte(INPUT_TEST_LOC+32)
    sta BufferDest+0

    lda TmpX
    beq @done
:
    lda InputLine+24, y
    sta BufferedTiles, y
    iny
    dec TmpX
    beq @done
    dex
    bne :-
    rts

@done:
    lda #0
:
    sta BufferedTiles, y
    iny
    dex
    bne :-
    rts

BufferLine3:
    ldy #0
    ldx #12
    stx BufferedLen

    lda #.hibyte(INPUT_TEST_LOC+64)
    sta BufferDest+1
    lda #.lobyte(INPUT_TEST_LOC+64)
    sta BufferDest+0

    lda TmpX
    beq @done
:
    lda InputLine+48, y
    sta BufferedTiles, y
    iny
    dec TmpX
    beq @done
    dex
    bne :-
    rts

@done:
    lda #0
:
    sta BufferedTiles, y
    iny
    dex
    bne :-
    rts

SetInspectorSprite:
    bne :+

    ; Left side
    sec
    lda SpriteCharPositionsX, x
    sbc #4
    sta InspectorSpriteAL+3

    sec
    lda SpriteCharPositionsY, x
    sbc #2
    sta InspectorSpriteAL+0

    ; Right side
    clc
    lda SpriteCharPositionsX, y
    adc #4
    sta InspectorSpriteAR+3
    lda SpriteCharPositionsY, y
    sta InspectorSpriteAR+0
    rts

:
    dex
    dey
    ; Left side
    sec
    lda SpriteCharPositionsX, x
    sbc #4
    sta InspectorSpriteBL+3

    lda SpriteCharPositionsY, x
    sta InspectorSpriteBL+0

    ; Right side
    clc
    lda SpriteCharPositionsX, y
    adc #4
    sta InspectorSpriteBR+3

    lda SpriteCharPositionsY, y
    sec
    sbc #2
    sta InspectorSpriteBR+0
    inx
    iny
    rts

;BinToAscii:
;    lda #1
;    tay
;    and TmpX
;    beq :+
;    inc TmpY
;:
;
;    tya
;    asl a
;    tay
;    and TmpX
;    beq :+
;    adc 
;:
;    rts

Part1_BufferRunning:
    ldx #0
:
    lda RunningSum, x
    ora #$30
    sta BufferedTiles, x
    inx
    cpx #5
    bne :-

    lda #5
    sta BufferedLen

    lda #$22
    sta BufferDest+1
    lda #$B3
    sta BufferDest+0

    ldx #0
    ldy #$20
:
    lda BufferedTiles, x
    cmp #$30
    bne :+

    sty BufferedTiles, x
    inx
    cpx #4
    bne :-
:
    rts

Part1_AddValue:
    ldx Part1_LastIdx
    lda InputLine, x
    and #$0F
    clc
    adc RunningSum+4
    sta RunningSum+4

:
    lda RunningSum+4
    cmp #10
    bcc :+
    sec
    sbc #10
    sta RunningSum+4
    inc RunningSum+3
    jmp :-
:

    ldx Part1_FirstIdx
    lda InputLine, x
    and #$0F
    clc
    adc RunningSum+3
    sta RunningSum+3

:
    lda RunningSum+3
    cmp #10
    bcc :+
    sec
    sbc #10
    sta RunningSum+3
    inc RunningSum+2
    jmp :-
:

:
    lda RunningSum+2
    cmp #10
    bcc :+
    sec
    sbc #10
    sta RunningSum+2
    inc RunningSum+1
    jmp :-
:

:
    lda RunningSum+1
    cmp #10
    bcc :+
    sec
    sbc #10
    sta RunningSum+1
    inc RunningSum+0
    jmp :-
:

    ;
    ; verify value
    ;
    lda RunningSum+4
    sta CurrentValueVerify+0
    lda #0
    sta CurrentValueVerify+1

    ;
    ; 10's
    ldx RunningSum+3
    lda Mult10, x
    clc
    adc CurrentValueVerify+0
    sta CurrentValueVerify+0

    ;
    ; 100's
    lda RunningSum+2
    asl a
    tax
    clc
    lda Mult100+0, x
    adc CurrentValueVerify+0
    sta CurrentValueVerify+0

    lda CurrentValueVerify+1
    adc #0
    sta CurrentValueVerify+1

    lda Mult100+1, x
    adc CurrentValueVerify+1
    sta CurrentValueVerify+1

    ;
    ; 1,000's
    lda RunningSum+1
    asl a
    tax
    clc
    lda Mult1k+0, x
    adc CurrentValueVerify+0
    sta CurrentValueVerify+0

    lda CurrentValueVerify+1
    adc #0
    sta CurrentValueVerify+1

    lda Mult1k+1, x
    adc CurrentValueVerify+1
    sta CurrentValueVerify+1

    ;
    ; 10,000's
    lda RunningSum+0
    asl a
    tax
    clc
    lda Mult10k+0, x
    adc CurrentValueVerify+0
    sta CurrentValueVerify+0

    lda CurrentValueVerify+1
    adc #0
    sta CurrentValueVerify+1

    lda Mult10k+1, x
    adc CurrentValueVerify+1
    sta CurrentValueVerify+1

    ldy #0
    lda (CurrentLineVerify), y
    cmp CurrentValueVerify+0
    bne @fail

    iny
    lda (CurrentLineVerify), y
    cmp CurrentValueVerify+1
    bne @fail

    clc
    lda CurrentLineVerify+0
    adc #2
    sta CurrentLineVerify+0

    lda CurrentLineVerify+1
    adc #0
    sta CurrentLineVerify+1

    rts
@fail:
    brk
    rts

BinToAscii:
    lda #0
    ldx #0
:   sta AsciiNumber, x
    inx
    cpx #5
    bne :-

    lda #$01 ; bit in byte
    sta TmpX
    ldy #0
@lowloop:
    lda BinNumber+0
    and TmpX
    beq @lownext

    lda NumberTable+4, y
    jsr bin_Add4

    lda NumberTable+3, y
    jsr bin_Add3

    lda NumberTable+2, y
    jsr bin_Add2

    lda NumberTable+1, y
    jsr bin_Add1

    lda NumberTable+0, y
    clc
    adc AsciiNumber+0
    sta AsciiNumber+0

@lownext:
    iny
    iny
    iny
    iny
    iny
    asl TmpX
    bne @lowloop

    lda #$01 ; bit in byte
    sta TmpX
@hiloop:
    lda BinNumber+1
    and TmpX
    beq @hinext

    lda NumberTable+4, y
    jsr bin_Add4

    lda NumberTable+3, y
    jsr bin_Add3

    lda NumberTable+2, y
    jsr bin_Add2

    lda NumberTable+1, y
    jsr bin_Add1

    lda NumberTable+0, y
    clc
    adc AsciiNumber+0
    sta AsciiNumber+0

@hinext:
    iny
    iny
    iny
    iny
    iny
    asl TmpX
    bne @hiloop

    ldx #0
:
    lda AsciiNumber, x
    ora #$30
    sta AsciiNumber, x
    inx
    cpx #5
    bne :-
    rts

bin_Add1:
    clc
    adc AsciiNumber+1
    sta AsciiNumber+1
    jmp bin_overflows

bin_Add2:
    clc
    adc AsciiNumber+2
    sta AsciiNumber+2
    jmp bin_overflows

bin_Add3:
    clc
    adc AsciiNumber+3
    sta AsciiNumber+3
    jmp bin_overflows

bin_Add4:
    clc
    adc AsciiNumber+4
    sta AsciiNumber+4

bin_overflows:
    ; check overflows
    lda AsciiNumber+4
    cmp #10
    bcc @over3

    sec
    sbc #10
    sta AsciiNumber+4
    inc AsciiNumber+3

@over3:
    lda AsciiNumber+3
    cmp #10
    bcc @over2

    sec
    sbc #10
    sta AsciiNumber+3
    inc AsciiNumber+2

@over2:
    lda AsciiNumber+2
    cmp #10
    bcc @over1

    sec
    sbc #10
    sta AsciiNumber+2
    inc AsciiNumber+1

@over1:
    lda AsciiNumber+1
    cmp #10
    bcc @over0

    sec
    sbc #10
    sta AsciiNumber+1
    inc AsciiNumber+0
@over0:
    rts

NumberTable:
    ;.repeat 16, i
    ;.word (1 << i)
    ;.out .sprintf("%d", (1 << i))

    .byte 0, 0, 0, 0, 1 ; "00001"
    .byte 0, 0, 0, 0, 2 ; "00002"
    .byte 0, 0, 0, 0, 4 ; "00004"
    .byte 0, 0, 0, 0, 8 ; "00008"
    .byte 0, 0, 0, 1, 6 ; "00016"
    .byte 0, 0, 0, 3, 2 ; "00032"
    .byte 0, 0, 0, 6, 4 ; "00064"
    .byte 0, 0, 1, 2, 8 ; "00128"
    .byte 0, 0, 2, 5, 6 ; "00256"
    .byte 0, 0, 5, 1, 2 ; "00512"
    .byte 0, 1, 0, 2, 4 ; "01024"
    .byte 0, 2, 0, 4, 8 ; "02048"
    .byte 0, 4, 0, 9, 6 ; "04096"
    .byte 0, 8, 1, 9, 2 ; "08192"
    .byte 1, 6, 3, 8, 4 ; "16384"
    .byte 3, 2, 7, 6, 8 ; "16384"

ClearScreen:

    lda #$20
    sta $2006
    lda #$00
    sta $2006

    ldy #0
    ldx #4
    lda #0
:
    sta $2007
    dey
    bne :-
    dex
    bne :-
    rts

WaitForNMI:
:   bit Sleeping
    bpl :-
    lda #0
    sta Sleeping
    rts

ReadControllers:
    lda Controller
    sta Controller_Old

    ; Freeze input
    lda #1
    sta $4016
    lda #0
    sta $4016

    LDX #$08
@player1:
    lda $4016
    lsr A           ; Bit0 -> Carry
    rol Controller ; Bit0 <- Carry
    dex
    bne @player1
    rts

; Was a button pressed this frame?
ButtonPressed:
    sta TmpX
    and Controller
    sta TmpY

    lda Controller_Old
    and TmpX

    cmp TmpY
    bne btnPress_stb

    ; no button change
    rts

btnPress_stb:
    ; button released
    lda TmpY
    bne btnPress_stc
    rts

btnPress_stc:
    ; button pressed
    lda #1
    rts

Part1_TextValues:
    .word :+
    .word :++
    .word :+++
    .word :++++

:   .asciiz "First Value"
:   .asciiz "Second Value"
:   .asciiz "Combined"
:   .asciiz "Running Balance"

Mult10:
    .repeat 10, i
    .byte i*10
    .endrepeat

Mult100:
    .repeat 10, i
    .word i*100
    .endrepeat

Mult1k:
    .repeat 10, i
    .word i*1000
    .endrepeat

Mult10k:
    .repeat 6, i
    .word i*10000
    .endrepeat

SpriteCharPositionsX:
    .repeat 24, i
    .byte 32+(i*8)
    .endrepeat

    .repeat 24, i
    .byte 32+(i*8)
    .endrepeat

    .repeat 12, i
    .byte 32+(i*8)
    .endrepeat

SpriteCharPositionsY:
    .repeat 24
    .byte 40
    .endrepeat

    .repeat 24
    .byte 48
    .endrepeat

    .repeat 12
    .byte 56
    .endrepeat

PaletteData:
    .repeat 4
    .byte $0F, $20, $10, $00
    .endrepeat

    .repeat 2
    .byte $0F, $21, $11, $31
    .byte $0F, $27, $17, $37
    .endrepeat

InputData:
    .incbin "../input.txt"
    .byte $00

VerifyData:
    .include "vals.i"
