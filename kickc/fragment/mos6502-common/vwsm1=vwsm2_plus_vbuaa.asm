clc
adc {m2}
sta {m1}
lda {m2}+1
adc #0
sta {m1}+1
