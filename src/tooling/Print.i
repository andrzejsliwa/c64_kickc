#import "FuncARGS.i"
#import "../memoryMap/KERNAL.i"
.namespace Print {

// +----------------------------------+
// Print.BinByte
// +----------------------------------+
BinByte:
    FuncARGS_NoOfArgs(1)
    FuncARGS_LoadAFrom(1)
    ldy #0
    sta variable
    lda #'%'
    jsr KERNAL.FFD2_output_vector
binaryPrint:
    asl variable
    lda #0
    adc #'0'
    jsr KERNAL.FFD2_output_vector
    iny
    cpy #8
    bne binaryPrint
    rts
variable:
    .byte 0



// +----------------------------------+
// Print.String
// +----------------------------------+
.var bas_lo = $14
.var bas_hi = $15

String:
    // a1 -> .byte msb
    // a2 -> .byte lsb

    FuncARGS_NoOfArgs(2)
    FuncARGS_LoadAFrom(2) // load msb
    sta bas_hi   // and store on ZP $15

    FuncARGS_LoadAFrom(1) // load lsb
    sta bas_lo   // and store on ZP $14

nextChar:
    ldy #0         // init y
    lda (bas_lo),y // load char at
                   // addr from
                   // bas_hi & bas_lo
    cmp #0         // if zero
    beq end        // then end

    jsr KERNAL.FFD2_output_vector // else print char
    clc
    inc bas_lo
    bne nextChar   // branch away if
                   // page not
                   // crossed
    inc bas_hi     // if crossed then
                   // inc page
    jmp nextChar   // continue print
end:
    rts

// +----------------------------------+
// Print.HexWord
// +----------------------------------+

HexWord:
    // a1 -> .byte msb
    // a2 -> .byte lsb
    FuncARGS_NoOfArgs(2)


    lda #'$'
    jsr KERNAL.FFD2_output_vector

    FuncARGS_LoadAFrom(2)
    jsr printHexByte

    FuncARGS_LoadAFrom(1)
    jsr printHexByte
    rts

// +----------------------------------+
// Print.HexByte
// +----------------------------------+
HexByte:
    FuncARGS_NoOfArgs(1)
    FuncARGS_LoadAFrom(1)

printHexByte:
    pha
    lsr
    lsr
    lsr
    lsr
    jsr printLsd
    pla
    jsr printLsd
    rts
printLsd:
    and #%00001111
    ora #'0'
    cmp #'9'+1
    bcc printChar
    adc #6
    jmp printChar

// +----------------------------------+
// Print.Char
// +----------------------------------+
Char:
    FuncARGS_NoOfArgs(1)
    FuncARGS_LoadAFrom(1)
printChar:
    jsr KERNAL.FFD2_output_vector
    rts
}
