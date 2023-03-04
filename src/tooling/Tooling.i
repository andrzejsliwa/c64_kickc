#import "FuncARGS.i"
.namespace Tooling {
    
Delay: 
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