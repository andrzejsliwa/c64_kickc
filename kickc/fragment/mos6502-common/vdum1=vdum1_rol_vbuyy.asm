cpy #0
cpy #0
beq !e+
!:
asl {m1}
rol {m1}+1
rol {m1}+2
rol {m1}+3
dey
bne !-
!e:
