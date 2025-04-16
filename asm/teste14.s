# s0 = 2048
addi s0, zero, 1024
slli s0, s0, 1
# s1 = 2052
addi s1, s0, 4

lui t0, 0x0FFFFF
sw t0, 0(s0)
