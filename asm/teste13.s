# s0 = 2048
addi s0, zero, 1024
slli s0, s0, 1
# s1 = 2052
addi s1, s0, 4

# jump to jalr_1 (address calculated manually since
# i don't think GAS allows using a label as an operand
# for jalr)
jalr ra, 24(zero)

# shouldn't happen
addi a0, zero, 1
sw a0, 0(s1)

jalr_1:
addi t0, zero, 1
sw t0, 0(s0)
sw ra, 0(s0)
