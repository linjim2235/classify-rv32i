.globl relu

.text
# ==============================================================================
# FUNCTION: Array ReLU Activation
#
# Applies ReLU (Rectified Linear Unit) operation in-place:
# For each element x in array: x = max(0, x)
#
# Arguments:
#   a0: Pointer to integer array to be modified
#   a1: Number of elements in array
#
# Returns:
#   None - Original array is modified directly
#
# Validation:
#   Requires non-empty array (length ≥ 1)
#   Terminates (code 36) if validation fails
#
# Example:
#   Input:  [-2, 0, 3, -1, 5]
#   Result: [ 0, 0, 3,  0, 5]
# ==============================================================================
relu:
    # Input validation
    li t0, 1             
    blt a1, t0, error    # if length < 1, error
    
    # Initialize counter
    li t1, 0             # t1 = i = 0
    
loop_start:
    bge t1, a1, loop_end # if i >= length, exit loop
    
    # Get current element
    slli t2, t1, 2       # t2 = i * 4 (offset)
    add t3, a0, t2       # t3 = array + offset
    lw t4, 0(t3)        # t4 = array[i]
    
    # Check if negative
    bge t4, zero, loop_continue # if array[i] >= 0, skip
    sw zero, 0(t3)      # array[i] = 0
    
loop_continue:
    addi t1, t1, 1      # i++
    j loop_start
    
loop_end:
    jr ra                # return

error:
    li a0, 36          
    j exit
    