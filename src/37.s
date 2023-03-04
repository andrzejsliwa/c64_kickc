#import "tooling/Tooling.i"

:BasicUpstart2(main)

.label screen_memory = $0400
.label color_memory = $d800

main:

loop:
  	ldy screen_memory
 	iny
  	sty screen_memory
	jsr Tooling.Delay
	.byte 200, 200
	jmp loop

