.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication Implementation
#
# Performs operation: D = M0 × M1
# Where:
#   - M0 is a (rows0 × cols0) matrix
#   - M1 is a (rows1 × cols1) matrix
#   - D is a (rows0 × cols1) result matrix
#
# Arguments:
#   First Matrix (M0):
#     a0: Memory address of first element
#     a1: Row count
#     a2: Column count
#
#   Second Matrix (M1):
#     a3: Memory address of first element
#     a4: Row count
#     a5: Column count
#
#   Output Matrix (D):
#     a6: Memory address for result storage
#
# Validation (in sequence):
#   1. Validates M0: Ensures positive dimensions
#   2. Validates M1: Ensures positive dimensions
#   3. Validates multiplication compatibility: M0_cols = M1_rows
#   All failures trigger program exit with code 38
#
# Output:
#   None explicit - Result matrix D populated in-place
# =======================================================
matmul:
   # Validate input dimensions
   li t0, 1
   blt a1, t0, invalid_dim   # rows of M0 must be >= 1
   blt a2, t0, invalid_dim   # cols of M0 must be >= 1
   blt a4, t0, invalid_dim   # rows of M1 must be >= 1
   blt a5, t0, invalid_dim   # cols of M1 must be >= 1
   bne a2, a4, invalid_dim   # M0 cols must equal M1 rows

   # Save registers and set up stack frame
   addi sp, sp, -28
   sw ra, 0(sp)
   sw s0, 4(sp)
   sw s1, 8(sp)
   sw s2, 12(sp)
   sw s3, 16(sp)
   sw s4, 20(sp)
   sw s5, 24(sp)

   # Initialize variables
   li s0, 0                  # Row counter for M0
   mv s2, a6                 # Result matrix address
   mv s3, a0                 # Base address of M0

matrix_row_loop:
   bge s0, a1, matrix_done   # Exit if row counter >= M0 rows
   li s1, 0                  # Column counter for M1
   mv s4, a3                 # Reset M1 column base address

matrix_col_loop:
   bge s1, a5, next_row      # Exit if column counter >= M1 cols

   # Save arguments before calling dot product
   addi sp, sp, -24
   sw a0, 0(sp)
   sw a1, 4(sp)
   sw a2, 8(sp)
   sw a3, 12(sp)
   sw a4, 16(sp)
   sw a5, 20(sp)

   # Set up arguments for dot product
   mv a0, s3                 # Row of M0
   mv a1, s4                 # Column of M1
   mv a2, a2                 # Number of elements (M0 cols = M1 rows)
   li a3, 1                  # Stride for M0
   mv a4, a5                 # Stride for M1 (M1 cols)

   # Call dot product
   jal ra, dot

   # Store the result
   sw a0, 0(s2)              # Store the dot product in the result matrix

   # Restore saved arguments
   lw a5, 20(sp)
   lw a4, 16(sp)
   lw a3, 12(sp)
   lw a2, 8(sp)
   lw a1, 4(sp)
   lw a0, 0(sp)
   addi sp, sp, 24

   # Move to the next column
   addi s2, s2, 4            # Increment result matrix pointer
   addi s4, s4, 4            # Increment M1 column pointer
   addi s1, s1, 1            # Increment column counter
   j matrix_col_loop          # Repeat for next column

next_row:
   # Move to the next row in M0
   slli t0, a2, 2            # Calculate row offset (M0 cols * 4 bytes)
   add s3, s3, t0            # Increment M0 pointer to the next row
   addi s0, s0, 1            # Increment row counter
   j matrix_row_loop          # Repeat for next row

matrix_done:
   # Restore registers and stack frame
   lw ra, 0(sp)
   lw s0, 4(sp)
   lw s1, 8(sp)
   lw s2, 12(sp)
   lw s3, 16(sp)
   lw s4, 20(sp)
   lw s5, 24(sp)
   addi sp, sp, 28
   jr ra

invalid_dim:
   li a0, 38                 # Error code for invalid dimensions
   j exit                    # Exit the program