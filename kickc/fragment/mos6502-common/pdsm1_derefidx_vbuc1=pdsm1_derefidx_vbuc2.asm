lda {m1}
sta $fe
lda {m1}+1
sta $ff
ldy #{c2}
lda ($fe),y
ldy #{c1}
sta ($fe),y
ldy #{c2}+1
lda ($fe),y
ldy #{c1}+1
sta ($fe),y
ldy #{c2}+2
lda ($fe),y
ldy #{c1}+2
sta ($fe),y
ldy #{c2}+3
lda ($fe),y
ldy #{c1}+3
sta ($fe),y