# s0 = 2048
addi s0, zero, 1024
slli s0, s0, 1
# s1 = 2052
addi s1, s0, 4

# beq test

add t0, zero, zero
add t1, zero, zero
beq t0, t1, beq_1

# shouldn't happen
addi a1, zero, 1
sw a1, 0(s1)

beq_1:
addi a0, zero, 1
sw a0, 0(s0)

addi t0, zero, 0
addi t1, zero, 1
beq t0, t1, beq_2

addi a0, zero, 2
sw a0, 0(s0)

beq_2:
nop

# bne test

add t0, zero, zero
addi t1, zero, 1
bne t0, t1, bne_1

# shouldn't happen
addi a1, zero, 2
sw a1, 0(s1)

bne_1:
addi a0, zero, 3
sw a0, 0(s0)

add t0, zero, zero
add t1, zero, zero
bne t0, t1, bne_2

addi a0, zero, 4
sw a0, 0(s0)

bne_2:
nop

# blt test

addi t0, zero, -1
addi t1, zero, 1
blt t0, t1, blt_1

# shouldn't happen
addi a1, zero, 3
sw a1, 0(s1)

blt_1:
addi a0, zero, 5
sw a0, 0(s0)

add t0, zero, -1
add t1, zero, -2
blt t0, t1, blt_2

addi a0, zero, 6
sw a0, 0(s0)

blt_2:
nop

# bge test

add t0, zero, 1
addi t1, zero, -1
bge t0, t1, bge_1

# shouldn't happen
addi a1, zero, 4
sw a1, 0(s1)

bge_1:
addi a0, zero, 7
sw a0, 0(s0)

add t0, zero, -2
add t1, zero, -1
bge t0, t1, bge_2

addi a0, zero, 8
sw a0, 0(s0)

bge_2:
nop

# bltu test

add t0, zero, 1
addi t1, zero, -1
bltu t0, t1, bltu_1

# shouldn't happen
addi a1, zero, 5
sw a1, 0(s1)

bltu_1:
addi a0, zero, 9
sw a0, 0(s0)

add t0, zero, -1
add t1, zero, -2
bltu t0, t1, bltu_2

addi a0, zero, 10
sw a0, 0(s0)

bltu_2:
nop
