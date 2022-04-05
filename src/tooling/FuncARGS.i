#importonce

// http://www.c64os.com/post/passinginlinearguments

.macro FuncARGS_NoOfArgs(no) {
    lda #no
    jsr setArgPtr
}

.macro FuncARGS_LoadAFrom(no) {
    ldy #no
    lda ($fc),y
}

setArgPtr:
    sta argc+1
    clc

    tsx
    lda $103,x
    sta $fc
argc:
    adc #0
    sta $0103,x

    lda $0104,x
    sta $fd
    adc #0
    sta $0104,x
    rts