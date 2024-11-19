.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Binary Matrix File Reader
#
# Loads matrix data from a binary file into dynamically allocated memory.
# Matrix dimensions are read from file header and stored at provided addresses.
#
# Binary File Format:
#   Header (8 bytes):
#     - Bytes 0-3: Number of rows (int32)
#     - Bytes 4-7: Number of columns (int32)
#   Data:
#     - Subsequent 4-byte blocks: Matrix elements
#     - Stored in row-major order: [row0|row1|row2|...]
#
# Arguments:
#   Input:
#     a0: Pointer to filename string
#     a1: Address to write row count
#     a2: Address to write column count
#
#   Output:
#     a0: Base address of loaded matrix
#
# Error Handling:
#   Program terminates with:
#   - Code 26: Dynamic memory allocation failed
#   - Code 27: File access error (open/EOF)
#   - Code 28: File closure error
#   - Code 29: Data read error
#
# Memory Note:
#   Caller is responsible for freeing returned matrix pointer
# ==============================================================================
read_matrix:
   # Prologue: Save caller-saved registers
   addi sp, sp, -40
   sw ra, 0(sp)
   sw s0, 4(sp)
   sw s1, 8(sp)
   sw s2, 12(sp)
   sw s3, 16(sp)
   sw s4, 20(sp)
   
   # Store addresses for row and column counts
   mv s3, a1          # Pointer to rows
   mv s4, a2          # Pointer to columns

   # Open file in read mode
   li a1, 0           # Mode: read
   jal fopen
   li t0, -1
   beq a0, t0, fopen_fail
   mv s0, a0          # Save file descriptor

   # Read the matrix dimensions (8 bytes total)
   mv a0, s0          # File descriptor
   addi a1, sp, 28    # Buffer to hold row and column data
   li a2, 8           # Number of bytes to read
   jal fread
   li t0, 8
   bne a0, t0, fread_fail

   # Extract rows and columns from buffer
   lw t1, 28(sp)      # Load row count from buffer
   lw t2, 32(sp)      # Load column count from buffer
   sw t1, 0(s3)       # Store row count at provided address
   sw t2, 0(s4)       # Store column count at provided address

   # Calculate total number of elements (rows * columns)
   mv s1, zero        # Accumulator for result
   mv t3, zero        # Loop counter
matrix_size_calc:
   beq t3, t2, size_calc_done
   add s1, s1, t1     # Accumulate number of elements
   addi t3, t3, 1
   j matrix_size_calc
size_calc_done:

   # Calculate total bytes needed (elements * 4 bytes)
   slli t3, s1, 2     # Multiply total elements by 4
   sw t3, 24(sp)      # Store size in stack

   # Allocate memory for the matrix
   lw a0, 24(sp)      # Number of bytes to allocate
   jal malloc
   beq a0, x0, malloc_fail
   mv s2, a0          # Store base address of allocated memory

   # Read matrix data from file
   mv a0, s0          # File descriptor
   mv a1, s2          # Pointer to allocated memory
   lw a2, 24(sp)      # Number of bytes to read
   jal fread
   lw t3, 24(sp)      # Load expected byte count
   bne a0, t3, fread_fail

   # Close the file
   mv a0, s0          # File descriptor
   jal fclose
   li t0, -1
   beq a0, t0, fclose_fail

   # Return pointer to matrix data
   mv a0, s2

   # Epilogue: Restore caller-saved registers
   lw ra, 0(sp)
   lw s0, 4(sp)
   lw s1, 8(sp)
   lw s2, 12(sp)
   lw s3, 16(sp)
   lw s4, 20(sp)
   addi sp, sp, 40
   jr ra

# Error handlers
malloc_fail:
   li a0, 26
   j exit_with_error
fopen_fail:
   li a0, 27
   j exit_with_error
fread_fail:
   li a0, 29
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
   addi sp, sp, 40
   j exit
