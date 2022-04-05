/// @file
/// Functions for performing input and output.
  // Commodore 64 PRG executable file
.file [name="helloworld.prg", type="prg", segments="Program"]
.segmentdef Program [segments="Basic, Code, Data"]
.segmentdef Basic [start=$0801]
.segmentdef Code [start=$80d]
.segmentdef Data [startAfter="Code"]
.segment Basic
:BasicUpstart(__start)
  .const LIGHT_BLUE = $e
  .const STACK_BASE = $103
  /// Color Ram
  .label COLORRAM = $d800
  /// Default address of screen character matrix
  .label DEFAULT_SCREEN = $400
  // The number of bytes on the screen
  // The current cursor x-position
  .label conio_cursor_x = $d
  // The current cursor y-position
  .label conio_cursor_y = 8
  // The current text cursor line start
  .label conio_line_text = $b
  // The current color cursor line start
  .label conio_line_color = 9
.segment Code
__start: {
    lda #0
    sta.z conio_cursor_x
    sta.z conio_cursor_y
    lda #<DEFAULT_SCREEN
    sta.z conio_line_text
    lda #>DEFAULT_SCREEN
    sta.z conio_line_text+1
    lda #<COLORRAM
    sta.z conio_line_color
    lda #>COLORRAM
    sta.z conio_line_color+1
    jsr conio_c64_init
    jsr main
    rts
}
// Set initial cursor position
conio_c64_init: {
    // Position cursor at current line
    .label BASIC_CURSOR_LINE = $d6
    ldx.z BASIC_CURSOR_LINE
    cpx #$19
    bcc __b1
    ldx #$19-1
  __b1:
    jsr gotoxy
    rts
}
// Output one character at the current cursor position
// Moves the cursor forward. Scrolls the entire screen if needed
// void cputc(__register(A) char c)
cputc: {
    .const OFFSET_STACK_C = 0
    tsx
    lda STACK_BASE+OFFSET_STACK_C,x
    cmp #'\n'
    beq __b1
    ldy.z conio_cursor_x
    sta (conio_line_text),y
    lda #LIGHT_BLUE
    sta (conio_line_color),y
    inc.z conio_cursor_x
    lda #$28
    cmp.z conio_cursor_x
    bne __breturn
    jsr cputln
  __breturn:
    rts
  __b1:
    jsr cputln
    rts
}
main: {
    jsr printf_str
    rts
  .segment Data
    s: .text @"hello world!\n"
    .byte 0
}
.segment Code
// Set the cursor to the specified position
// void gotoxy(char x, __register(X) char y)
gotoxy: {
    .const x = 0
    .label __5 = $14
    .label __6 = $10
    .label __7 = $10
    .label line_offset = $10
    .label __8 = $12
    .label __9 = $10
    cpx #$19+1
    bcc __b2
    ldx #0
  __b2:
    lda #x
    sta.z conio_cursor_x
    stx.z conio_cursor_y
    txa
    sta.z __7
    lda #0
    sta.z __7+1
    lda.z __7
    asl
    sta.z __8
    lda.z __7+1
    rol
    sta.z __8+1
    asl.z __8
    rol.z __8+1
    clc
    lda.z __9
    adc.z __8
    sta.z __9
    lda.z __9+1
    adc.z __8+1
    sta.z __9+1
    asl.z line_offset
    rol.z line_offset+1
    asl.z line_offset
    rol.z line_offset+1
    asl.z line_offset
    rol.z line_offset+1
    lda.z line_offset
    clc
    adc #<DEFAULT_SCREEN
    sta.z __5
    lda.z line_offset+1
    adc #>DEFAULT_SCREEN
    sta.z __5+1
    lda.z __5
    sta.z conio_line_text
    lda.z __5+1
    sta.z conio_line_text+1
    lda.z __6
    clc
    adc #<COLORRAM
    sta.z __6
    lda.z __6+1
    adc #>COLORRAM
    sta.z __6+1
    lda.z __6
    sta.z conio_line_color
    lda.z __6+1
    sta.z conio_line_color+1
    rts
}
// Print a newline
cputln: {
    lda #$28
    clc
    adc.z conio_line_text
    sta.z conio_line_text
    bcc !+
    inc.z conio_line_text+1
  !:
    lda #$28
    clc
    adc.z conio_line_color
    sta.z conio_line_color
    bcc !+
    inc.z conio_line_color+1
  !:
    lda #0
    sta.z conio_cursor_x
    inc.z conio_cursor_y
    jsr cscroll
    rts
}
/// Print a NUL-terminated string
// void printf_str(void (*putc)(char), __zp($e) const char *s)
printf_str: {
    .label s = $e
    lda #<main.s
    sta.z s
    lda #>main.s
    sta.z s+1
  __b1:
    ldy #0
    lda (s),y
    inc.z s
    bne !+
    inc.z s+1
  !:
    cmp #0
    bne __b2
    rts
  __b2:
    pha
    jsr cputc
    pla
    jmp __b1
}
// Scroll the entire screen if the cursor is beyond the last line
cscroll: {
    lda #$19
    cmp.z conio_cursor_y
    bne __breturn
    lda #<DEFAULT_SCREEN
    sta.z memcpy.destination
    lda #>DEFAULT_SCREEN
    sta.z memcpy.destination+1
    lda #<DEFAULT_SCREEN+$28
    sta.z memcpy.source
    lda #>DEFAULT_SCREEN+$28
    sta.z memcpy.source+1
    jsr memcpy
    lda #<COLORRAM
    sta.z memcpy.destination
    lda #>COLORRAM
    sta.z memcpy.destination+1
    lda #<COLORRAM+$28
    sta.z memcpy.source
    lda #>COLORRAM+$28
    sta.z memcpy.source+1
    jsr memcpy
    ldx #' '
    lda #<DEFAULT_SCREEN+$19*$28-$28
    sta.z memset.str
    lda #>DEFAULT_SCREEN+$19*$28-$28
    sta.z memset.str+1
    jsr memset
    ldx #LIGHT_BLUE
    lda #<COLORRAM+$19*$28-$28
    sta.z memset.str
    lda #>COLORRAM+$19*$28-$28
    sta.z memset.str+1
    jsr memset
    sec
    lda.z conio_line_text
    sbc #$28
    sta.z conio_line_text
    lda.z conio_line_text+1
    sbc #0
    sta.z conio_line_text+1
    sec
    lda.z conio_line_color
    sbc #$28
    sta.z conio_line_color
    lda.z conio_line_color+1
    sbc #0
    sta.z conio_line_color+1
    dec.z conio_cursor_y
  __breturn:
    rts
}
// Copy block of memory (forwards)
// Copies the values of num bytes from the location pointed to by source directly to the memory block pointed to by destination.
// void * memcpy(__zp(4) void *destination, __zp(2) void *source, unsigned int num)
memcpy: {
    .label src_end = 6
    .label dst = 4
    .label src = 2
    .label source = 2
    .label destination = 4
    lda.z source
    clc
    adc #<$19*$28-$28
    sta.z src_end
    lda.z source+1
    adc #>$19*$28-$28
    sta.z src_end+1
  __b1:
    lda.z src+1
    cmp.z src_end+1
    bne __b2
    lda.z src
    cmp.z src_end
    bne __b2
    rts
  __b2:
    ldy #0
    lda (src),y
    sta (dst),y
    inc.z dst
    bne !+
    inc.z dst+1
  !:
    inc.z src
    bne !+
    inc.z src+1
  !:
    jmp __b1
}
// Copies the character c (an unsigned char) to the first num characters of the object pointed to by the argument str.
// void * memset(__zp(2) void *str, __register(X) char c, unsigned int num)
memset: {
    .label end = 4
    .label dst = 2
    .label str = 2
    lda #$28
    clc
    adc.z str
    sta.z end
    lda #0
    adc.z str+1
    sta.z end+1
  __b2:
    lda.z dst+1
    cmp.z end+1
    bne __b3
    lda.z dst
    cmp.z end
    bne __b3
    rts
  __b3:
    txa
    ldy #0
    sta (dst),y
    inc.z dst
    bne !+
    inc.z dst+1
  !:
    jmp __b2
}
