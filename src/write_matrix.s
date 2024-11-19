.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Write a matrix of integers to a binary file
# FILE FORMAT:
#   - The first 8 bytes store two 4-byte integers representing the number of 
#     rows and columns, respectively.
#   - Each subsequent 4-byte segment represents a matrix element, stored in 
#     row-major order.
#
# Arguments:
#   a0 (char *) - Pointer to a string representing the filename.
#   a1 (int *)  - Pointer to the matrix's starting location in memory.
#   a2 (int)    - Number of rows in the matrix.
#   a3 (int)    - Number of columns in the matrix.
#
# Returns:
#   None
#
# Exceptions:
#   - Terminates with error code 27 on `fopen` error or end-of-file (EOF).
#   - Terminates with error code 28 on `fclose` error or EOF.
#   - Terminates with error code 30 on `fwrite` error or EOF.
# ==============================================================================
write_matrix:
   # Prologue: Save registers to the stack
   addi sp, sp, -44
   sw ra, 0(sp)
   sw s0, 4(sp)
   sw s1, 8(sp)
   sw s2, 12(sp)
   sw s3, 16(sp)
   sw s4, 20(sp)
   
   # Store function arguments
   mv s1, a1          # Pointer to matrix
   mv s2, a2          # Number of rows
   mv s3, a3          # Number of columns

   # Open file in write mode
   li a1, 1           # Mode: write
   jal fopen
   li t0, -1
   beq a0, t0, fopen_fail
   mv s0, a0          # Save file descriptor

   # Write the matrix dimensions to the file
   sw s2, 24(sp)      # Store rows in stack
   sw s3, 28(sp)      # Store columns in stack
   mv a0, s0          # File descriptor
   addi a1, sp, 24    # Buffer pointer to rows and columns
   li a2, 2           # Write two integers
   li a3, 4           # Size of each integer
   jal fwrite
   li t0, 2
   bne a0, t0, fwrite_fail

   # Calculate total number of elements (rows * columns)
   mv s4, zero        # Result accumulator for multiplication
   mv t0, zero        # Loop counter
matrix_element_count:
   beq t0, s3, count_done
   add s4, s4, s2     # Accumulate rows
   addi t0, t0, 1
   j matrix_element_count
count_done:

   # Write the matrix data to the file
   mv a0, s0          # File descriptor
   mv a1, s1          # Pointer to matrix data
   mv a2, s4          # Number of elements
   li a3, 4           # Size of each element
   jal fwrite
   bne a0, s4, fwrite_fail

   # Close the file
   mv a0, s0          # File descriptor
   jal fclose
   li t0, -1
   beq a0, t0, fclose_fail

   # Epilogue: Restore registers and return
   lw ra, 0(sp)
   lw s0, 4(sp)
   lw s1, 8(sp)
   lw s2, 12(sp)
   lw s3, 16(sp)
   lw s4, 20(sp)
   addi sp, sp, 44
   jr ra

# Error handlers
fopen_fail:
   li a0, 27
   j exit_with_error
fwrite_fail:
   li a0, 30
   j exit_with_error
fclose_fail:
   li a0, 28
   j exit_with_error
exit_with_error:
   lw ra, 0(sp)
   lw s0, 4(sp)
   lw s1, 8(sp)
   lw s2, 12(sp)
   lw s3, 16(sp)
   lw s4, 20(sp)
   addi sp, sp, 44
   j exit
