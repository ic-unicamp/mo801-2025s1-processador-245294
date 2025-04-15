# s0 = 2048
addi s0, zero, 1024
slli s0, s0, 1
# s1 = 2052
addi s1, s0, 4

jal ra, jal_1

# shouldn't happen
addi a0, zero, 1
sw a0, 0(s1)

jal_2:
addi t0, zero, 0x02
sw t0, 0(s0)
sw ra, 0(s0)
jal ra, jal_3

# shouldn't happen
addi a0, zero, 2
sw a0, 0(s1)

jal_1:
addi t0, zero, 0x01
sw t0, 0(s0)
sw ra, 0(s0)
jal ra, jal_2

# shouldn't happen
addi a0, zero, 3
sw a0, 0(s1)

jal_3:
addi t0, zero, 0x03
sw t0, 0(s0)
sw ra, 0(s0)
