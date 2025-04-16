# s0 = 0x800
addi s0, zero, 1024
slli s0, s0, 1
# s0 = 0x804
addi s1, s0, 4

addi t0, zero, -1
sb t0, 0(s0)
sh t0, 0(s0)
sw t0, 0(s0)

# [2049] = 0xFFFFFFFF
addi t0, zero, -1
sw t0, 0(s1)

lb t0, 0(s1)
sw t0, 0(s0)

lh t0, 0(s1)
sw t0, 0(s0)

lh t0, 0(s1)
sw t0, 0(s0)

lbu t0, 0(s1)
sw t0, 0(s0)

lhu t0, 0(s1)
sw t0, 0(s0)
