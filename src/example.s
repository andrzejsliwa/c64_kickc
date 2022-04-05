*=$0801 "Basic Upstart"
:BasicUpstart2(start)

// Main program
*=$080d "Program"
start:
    jmp main

#import "tooling/Print.i"
#import "memoryMap/KERNAL.i"

.encoding "petscii_upper"

main:
    jsr Print.HexWord
    .word $1234

    jsr Print.String
    .word message

    lda #128
    sta byteArg

    jsr Print.BinByte
byteArg:
	.byte $0f

    jmp *

message:
    .text "HELLO WORLD!"
    .byte 0
