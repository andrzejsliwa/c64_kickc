clc
lda {c1},x
adc #{c2}
sta {c1},y
lda {c1}+1,x
adc #0
sta {c1}+1,y