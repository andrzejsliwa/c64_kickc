*=$0801 "Basic Upstart"
:BasicUpstart2(start)

.const SPACE = $20
start:
loop:
    ldy column
    dey
    lda FALLING_ORDER, y
    tay

    dey
    ldx row
    dex
    lda SCREEN_ROW_LSB, x
    sta $10
    lda SCREEN_ROW_MSB, x
    sta $11

    lda #1
    lda ($10), y   
    sta character
    cmp #SPACE
    beq continue

    ldy column
    dey
    lda FALLING_ORDER, y
    tay
    ldx row
    jsr move_down

continue:
    dec column
    bne loop

    dec row
    beq end
    
    lda #40
    sta column
    jmp loop
end:
    rts

move_down:
    stx local_row
    sty local_column

move_loop:
	// jsr Tooling.Delay
	// .byte 200, 1

    lda local_row
    cmp #25
    beq end_move

    ldy local_column
    dey
    ldx local_row
    dex
    inx 
    lda SCREEN_ROW_LSB, x 
    sta $10
    lda SCREEN_ROW_MSB, x
    sta $11    
    lda ($10), y 
    cmp #SPACE
    bne end_move

    ldy local_column
    dey
    ldx local_row
    dex
    lda SCREEN_ROW_LSB, x
    sta $10
    lda SCREEN_ROW_MSB, x
    sta $11    
    lda #SPACE
    sta ($10), y 

    ldy local_column
    dey
    ldx local_row
    dex
    inx 
    lda SCREEN_ROW_LSB, x
    sta $10
    lda SCREEN_ROW_MSB, x
    sta $11    
    lda character
    sta ($10), y 

    inc local_row
    jmp move_loop
 end_move:
    rts

local_row:    .byte 0
local_column: .byte 0

column:       .byte 40 
row:          .byte 25
character:    .byte 0
SCREEN_ROW_LSB: .fill 25, <[$0400 + i * 40]
SCREEN_ROW_MSB: .fill 25, >[$0400 + i * 40]

.var columns = List()
.for(var i=0; i<40; i++) {
    .eval columns.add(i + 1)
}
.var random_columns = columns.shuffle()

FALLING_ORDER: 
.fill 40, random_columns.get(i)

#import "tooling/Tooling.i"