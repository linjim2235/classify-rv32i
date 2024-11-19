.globl classify

.text
# =====================================
# NEURAL NETWORK CLASSIFIER
# =====================================
# Description:
#   Command line program for matrix-based classification
#
# Command Line Arguments:
#   1. M0_PATH      - First matrix file location
#   2. M1_PATH      - Second matrix file location
#   3. INPUT_PATH   - Input matrix file location
#   4. OUTPUT_PATH  - Output file destination
#
# Register Usage:
#   a0 (int)        - Input: Argument count
#                   - Output: Classification result
#   a1 (char **)    - Input: Argument vector
#   a2 (int)        - Input: Silent mode flag
#                     (0 = verbose, 1 = silent)
#
# Error Codes:
#   31 - Invalid argument count
#   26 - Memory allocation failure
#
# Usage Example:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
# =====================================
classify:
    # Check for correct number of arguments
    li t0, 5
    blt a0, t0, invalid_args

    # Allocate stack space
    addi sp, sp, -48
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)
    sw s9, 40(sp)
    sw s10, 44(sp)

    # Read M0 matrix
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    li a0, 4
    jal malloc
    beq a0, x0, malloc_error
    mv s3, a0
    li a0, 4
    jal malloc
    beq a0, x0, malloc_error
    mv s4, a0
    lw a1, 4(sp)
    lw a0, 4(a1)
    mv a1, s3
    mv a2, s4
    jal read_matrix
    mv s0, a0
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12

    # Read M1 matrix
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    li a0, 4
    jal malloc
    beq a0, x0, malloc_error
    mv s5, a0
    li a0, 4
    jal malloc
    beq a0, x0, malloc_error
    mv s6, a0
    lw a1, 4(sp)
    lw a0, 8(a1)
    mv a1, s5
    mv a2, s6
    jal read_matrix
    mv s1, a0
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12

    # Read input matrix
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    li a0, 4
    jal malloc
    beq a0, x0, malloc_error
    mv s7, a0
    li a0, 4
    jal malloc
    beq a0, x0, malloc_error
    mv s8, a0
    lw a1, 4(sp)
    lw a0, 12(a1)
    mv a1, s7
    mv a2, s8
    jal read_matrix
    mv s2, a0
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12

    # Compute h = matmul(m0, input)
    addi sp, sp, -28
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    lw t0, 0(s3)
    lw t1, 0(s8)
    # Custom multiplication implementation (inlined)
    li t2, 0
    mv t3, t0
    mv t4, t1
    li t5, 0
mul_loop_h:
    andi t6, t4, 1
    beqz t6, skip_add_h
    add t5, t5, t3
skip_add_h:
    slli t3, t3, 1
    srli t4, t4, 1
    bnez t4, mul_loop_h
    slli t5, t5, 2
    li a0, 0
    mv a0, t5
    jal malloc
    beq a0, x0, malloc_error
    mv s9, a0
    mv a6, a0
    mv a0, s0
    lw a1, 0(s3)
    lw a2, 0(s4)
    mv a3, s2
    lw a4, 0(s7)
    lw a5, 0(s8)
    jal matmul
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    addi sp, sp, 28

    # ReLU activation function for h
    addi sp, sp, -8
    sw a0, 0(sp)
    sw a1, 4(sp)
    mv a0, s9
    lw t0, 0(s3)
    lw t1, 0(s8)
    # Custom multiplication (inlined)
    li t2, 0
    mv t3, t0
    mv t4, t1
    li t5, 0
mul_loop_relu:
    andi t6, t4, 1
    beqz t6, skip_add_relu
    add t5, t5, t3
skip_add_relu:
    slli t3, t3, 1
    srli t4, t4, 1
    bnez t4, mul_loop_relu
    mv a1, t5
    jal relu
    lw a0, 0(sp)
    lw a1, 4(sp)
    addi sp, sp, 8

    # Compute o = matmul(m1, h)
    addi sp, sp, -28
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    lw t0, 0(s3)
    lw t1, 0(s6)
    # Custom multiplication implementation (inlined)
    li t2, 0
    mv t3, t0
    mv t4, t1
    li t5, 0
mul_loop_o:
    andi t6, t4, 1
    beqz t6, skip_add_o
    add t5, t5, t3
skip_add_o:
    slli t3, t3, 1
    srli t4, t4, 1
    bnez t4, mul_loop_o
    slli t5, t5, 2
    li a0, 0
    mv a0, t5
    jal malloc
    beq a0, x0, malloc_error
    mv s10, a0
    mv a6, a0
    mv a0, s1
    lw a1, 0(s5)
    lw a2, 0(s6)
    mv a3, s9
    lw a4, 0(s3)
    lw a5, 0(s8)
    jal matmul
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    addi sp, sp, 28

    # Write output matrix o to file
    addi sp, sp, -16
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    lw a0, 16(a1)
    mv a1, s10
    lw a2, 0(s5)
    lw a3, 0(s8)
    jal write_matrix
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    addi sp, sp, 16

    # Compute argmax for output o
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    mv a0, s10
    lw t0, 0(s3)
    lw t1, 0(s6)
    # Custom multiplication (inlined)
    li t2, 0
    mv t3, t0
    mv t4, t1
    li t5, 0
mul_loop_argmax:
    andi t6, t4, 1
    beqz t6, skip_add_argmax
    add t5, t5, t3
skip_add_argmax:
    slli t3, t3, 1
    srli t4, t4, 1
    bnez t4, mul_loop_argmax
    mv a1, t5
    jal argmax
    mv t0, a0
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12
    mv a0, t0

    # Print the classification result if not in silent mode
    bne a2, x0, finalize
    addi sp, sp, -4
    sw a0, 0(sp)
    jal print_int
    li a0, '\n'
    jal print_char
    lw a0, 0(sp)
    addi sp, sp, 4

# Final cleanup and memory deallocation
finalize:
    addi sp, sp, -4
    sw a0, 0(sp)
    mv a0, s0
    jal free
    mv a0, s1
    jal free
    mv a0, s2
    jal free
    mv a0, s3
    jal free
    mv a0, s4
    jal free
    mv a0, s5
    jal free
    mv a0, s6
    jal free
    mv a0, s7
    jal free
    mv a0, s8
    jal free
    mv a0, s9
    jal free
    mv a0, s10
    jal free
    lw a0, 0(sp)
    addi sp, sp, 4

    # Restore registers and return
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    lw s9, 40(sp)
    lw s10, 44(sp)
    addi sp, sp, 48
    jr ra

# Error handling for invalid argument count
invalid_args:
    li a0, 31
    j exit

# Error handling for malloc failure
malloc_error:
    li a0, 26
    j exit
