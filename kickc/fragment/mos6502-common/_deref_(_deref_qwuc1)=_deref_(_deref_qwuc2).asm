ldy {c2}
sty $fe
ldy {c2}+1
sty $ff
ldy #0
lda ($fe),y
ldy {c1}
sty $fe
ldy {c1}+1
sty $ff
ldy #0
sta ($fe),y