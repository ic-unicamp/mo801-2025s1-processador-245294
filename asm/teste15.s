# s0 = 2048
addi s0, zero, 1024
slli s0, s0, 1
# s1 = 2052
addi s1, s0, 4

auipc t0, 0
sw t0, 0(s0)
auipc t0, 1
sw t0, 0(s0)
auipc t0, 0x10000
sw t0, 0(s0)
