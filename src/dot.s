.globl dot

.text
# =======================================================
# FUNCTION: Strided Dot Product Calculator
#
# Calculates sum(arr0[i * stride0] * arr1[i * stride1])
# where i ranges from 0 to (element_count - 1)
#
# Args:
#   a0 (int *): Pointer to first input array
#   a1 (int *): Pointer to second input array
#   a2 (int):   Number of elements to process
#   a3 (int):   Skip distance in first array
#   a4 (int):   Skip distance in second array
#
# Returns:
#   a0 (int):   Resulting dot product value
#
# Preconditions:
#   - Element count must be positive (>= 1)
#   - Both strides must be positive (>= 1)
#
# Error Handling:
#   - Exits with code 36 if element count < 1
#   - Exits with code 37 if any stride < 1
# =======================================================
dot:
    # Validate input arguments
    li t0, 1
    blt a2, t0, invalid_element_count # Check if element count < 1
    blt a3, t0, invalid_stride        # Check if first stride < 1
    blt a4, t0, invalid_stride        # Check if second stride < 1

    # Initialize registers for computation
    li t0, 0              # Accumulate the dot product (result = 0)
    li t1, 0              # Index for iteration (i = 0)

dot_loop:
    bge t1, a2, finish    # Exit loop if i >= element_count

    # Calculate addresses of current elements in arr0 and arr1
    mul t2, t1, a3        # Offset for arr0: i * stride0
    slli t2, t2, 2        # Convert to byte offset (4 bytes per element)
    add t2, a0, t2        # Address of arr0[i * stride0]
    lw t3, 0(t2)          # Load arr0[i * stride0] into t3

    mul t4, t1, a4        # Offset for arr1: i * stride1
    slli t4, t4, 2        # Convert to byte offset (4 bytes per element)
    add t4, a1, t4        # Address of arr1[i * stride1]
    lw t5, 0(t4)          # Load arr1[i * stride1] into t5

    # Multiply current elements and add to the result
    mul t6, t3, t5        # Multiply: arr0[i] * arr1[i]
    add t0, t0, t6        # Accumulate: result += arr0[i] * arr1[i]

    # Move to the next index
    addi t1, t1, 1        # i++

    # Repeat the loop
    j dot_loop

finish:
    # Return the dot product result
    mv a0, t0
    jr ra

# Error handling
invalid_element_count:
    li a0, 36             # Error: Invalid element count
    j exit

invalid_stride:
    li a0, 37             # Error: Invalid stride
    j exit