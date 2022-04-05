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
    lda a
    sec
    sbc b
    sta result
    lda a + 1
    sbc b + 1
    sta result + 1
    .break
    jsr Print.HexWord
result:
    .word 0
    rts
a: .word $e615
b: .word $7198

// adding 2 words
// main:
//     lda a
//     clc
//     adc b
//     sta result
//     lda a + 1
//     adc b + 1
//     sta result + 1
//     jsr Print.HexWord
// result:
//     .word 0
//     rts
// a: .word $6c67
// b: .word $49b2