:BasicUpstart2(main)

.const SCREEN_MEMORY = $0400
.const COLOR_MEMORY  = $d800
.const FILLED_CHAR   = 160

* = $1000 "Main"
main:

    lda #FILLED_CHAR
    ldx #10
  loopx1:
    .for(var i = 0; i < 100; i++) {
      sta SCREEN_MEMORY + i*10 - 1, X
    }
    dex
    beq endloopx1
  jmp loopx1
  endloopx1:

    ldx #250
  loopx2:
    .for(var i = 0; i < 4; i++) {
      lda image + i*250 - 1, X
      sta COLOR_MEMORY + i*250 - 1, X
    }
    dex
  bne loopx2

end:
  jmp end

* = * "Data"
image:
  .byte 14,14,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,14,14
  .byte 14,9,9,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,9,9,14
  .byte 9,9,9,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,9,9,9
  .byte 9,9,9,9,9,9,9,9,9,9,1,1,1,1,1,1,9,9,9,9,9,9,9,9,9,1,1,1,1,9,9,9,9,9,9,9,9,9,9,9
  .byte 9,9,9,8,8,8,8,8,8,1,1,1,1,1,1,1,1,1,8,8,8,8,8,8,1,1,12,1,1,12,8,8,8,8,8,8,8,9,9,9
  .byte 9,9,9,8,8,8,8,8,1,1,12,12,12,12,12,12,1,1,12,8,8,8,8,1,1,12,8,1,1,12,8,8,8,8,8,8,8,9,9,9
  .byte 9,9,9,9,9,9,9,9,1,1,11,9,9,9,9,9,9,11,11,9,9,9,1,1,11,9,9,1,1,11,9,9,9,9,9,9,9,9,9,9
  .byte 9,9,9,7,7,7,7,7,1,1,15,1,1,1,1,1,1,7,7,7,7,1,1,15,7,7,7,1,1,15,7,7,7,7,7,7,7,9,9,9
  .byte 9,9,9,7,7,7,7,7,1,1,1,1,1,1,1,1,1,1,7,7,1,1,15,7,7,7,7,1,1,15,7,7,7,7,7,7,7,9,9,9
  .byte 9,9,9,9,9,9,9,9,1,1,11,11,11,11,11,11,1,1,11,9,1,1,1,1,1,1,1,1,1,1,1,9,9,9,9,9,9,9,9,9
  .byte 9,9,9,5,5,5,5,5,1,1,12,5,5,5,5,5,1,1,12,5,1,1,1,1,1,1,1,1,1,1,1,12,5,5,5,5,5,9,9,9
  .byte 9,9,9,5,5,5,5,5,1,1,1,1,1,1,1,1,1,1,12,5,5,12,12,12,12,12,12,1,1,12,12,12,5,5,5,5,5,9,9,9
  .byte 9,9,9,9,9,9,9,9,9,1,1,1,1,1,1,1,1,11,11,9,9,9,9,9,9,9,9,1,1,11,9,9,9,9,9,9,9,9,9,9
  .byte 9,9,9,6,6,6,6,6,6,6,12,12,12,12,12,12,12,12,6,6,6,6,6,6,6,6,6,6,12,12,6,6,6,6,6,6,6,9,9,9
  .byte 9,9,9,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,9,9,9
  .byte 9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9
  .byte 9,9,9,9,1,9,9,9,9,9,9,9,1,1,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9
  .byte 9,9,9,9,1,9,9,9,9,9,9,9,9,9,9,9,1,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9
  .byte 9,9,9,9,1,9,1,1,1,9,9,9,1,9,9,1,1,1,1,1,9,9,9,1,1,1,1,9,9,9,1,1,1,1,1,9,9,9,9,9
  .byte 9,9,9,9,1,1,9,9,1,1,9,9,1,1,9,9,1,9,9,9,9,9,1,9,9,9,1,1,9,1,1,9,9,9,9,9,9,9,9,9
  .byte 9,9,9,9,1,9,9,9,9,1,9,9,1,1,9,9,1,9,9,9,9,1,1,1,1,1,1,1,9,1,1,1,1,1,1,1,9,9,9,9
  .byte 9,9,9,9,1,1,9,9,1,1,9,9,1,1,9,9,1,9,9,1,9,9,1,9,9,9,9,9,9,9,9,9,9,9,1,1,9,9,9,9
  .byte 9,9,9,9,1,9,1,1,1,9,9,9,1,1,9,9,1,1,1,1,9,9,9,1,1,1,1,9,9,9,1,1,1,1,1,9,9,9,9,9
  .byte 14,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,14
  .byte 14,14,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,14,14

