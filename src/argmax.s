.globl argmax

.text
# =================================================================
# FUNCTION: Maximum Element First Index Finder
#
# Scans an integer array to find its maximum value and returns the
# position of its first occurrence. In cases where multiple elements
# share the maximum value, returns the smallest index.
#
# Arguments:
#   a0 (int *): Pointer to the first element of the array
#   a1 (int):  Number of elements in the array
#
# Returns:
#   a0 (int):  Position of the first maximum element (0-based index)
#
# Preconditions:
#   - Array must contain at least one element
#
# Error Cases:
#   - Terminates program with exit code 36 if array length < 1
# =================================================================
argmax:
    # Validate input arguments
    li t0, 1                # Minimum valid array size
    blt a1, t0, error_exit  # If size < 1, jump to error handler

    # Initialize variables
    lw t1, 0(a0)            # t1 = max_value = array[0]
    li t2, 0                # t2 = max_index = 0
    li t3, 1                # t3 = current_index = 1

search_loop:
    bge t3, a1, search_done # If current_index >= size, end loop

    # Calculate the address of the current element
    slli t4, t3, 2          # t4 = current_index * 4 (bytes per int)
    add t5, a0, t4          # t5 = address of array[current_index]
    lw t6, 0(t5)            # t6 = array[current_index]

    # Compare current element with the maximum value
    ble t6, t1, skip_update # If array[current_index] <= max_value, skip
    mv t1, t6               # max_value = array[current_index]
    mv t2, t3               # max_index = current_index

skip_update:
    addi t3, t3, 1          # Increment current_index
    j search_loop           # Repeat the loop

search_done:
    mv a0, t2               # Return max_index
    jr ra                   # Return to caller

# Error handler for invalid array size
error_exit:
    li a0, 36               # Set error code for invalid array size
    j exit                  # Terminate program