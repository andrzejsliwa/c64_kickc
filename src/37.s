#import "tooling/FuncARGS.i"

:BasicUpstart2(main)

.label screen_memory = $0400
.label color_memory = $d800

main:

loop:
  	ldy screen_memory
 	iny
  	sty screen_memory
	jsr delay
	.byte 200, 50
	jmp loop

.macro Delay(delay_outer, delay_inner) {
    ldy #delay_outer
  loopy:
    ldx #delay_inner
  loopx:
    nop
    dex
    bne loopx
    dey
    bne loopy
}

delay: {
	FuncARGS_NoOfArgs(2)
	FuncARGS_LoadAFrom(1)
	sta delay_outer
	FuncARGS_LoadAFrom(2)
	sta delay_inner

	ldy delay_outer
loopy:
	ldx delay_inner
loopx:
	nop
	dex
	bne loopx
	dey
	bne loopy
	rts
delay_outer: .byte 0
delay_inner: .byte 0
}
