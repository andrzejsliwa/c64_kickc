lda {m1}+1
bmi {la1}
bne !+
lda {m1}
cmp {m2}
bcc {la1}
!:
