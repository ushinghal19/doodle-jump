# Demo for painting
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#

# Code Structure
# 1. Check for Keyboard Input
	# Update location of doodler
	
	# Check for collision

# 2.Update the location of all platforms and other objects

# 3.Redraw the screen

# 4.Sleep

# 5.Go to Step 1



.data
displayAddress: .word 0x10008000
displayMax: .word 0x10009000
doodlerLocation: .word 0x10008fc0

.text
lw $s0, displayAddress 	# $s0 stores the base address for display
lw $s1, displayMax	# $s1 stores the maximum display
lw $s2, doodlerLocation # $s2 stores the doodler's location
li $s3, 0xe6f7eb	# $s3 stores the background colour
li $s4, 0x821012	# $s4 stores the platform colour
li $s5, 0x0b2773	# $s5 stores the doodler colour

# Main =====================================================
main:
jal DRAW_BACKGROUND
jal DRAW_DOODLER
jal DRAW_PLATFORM
j Exit
# ==========================================================

# Functions ================================================

# Background
DRAW_BACKGROUND:
add $t9, $zero, $s0	# $t9 stores the value of the base address

LOOP:			# For loop through each pixel
sw $s3, 0($t9)		# Overwriting the colour at address $t9
beq $t9, $s1, END	# Checking if $t9 reached the max

UPDATE:
addi $t9, $t9, 4
j LOOP

END: 
jr $ra

# Doodler
DRAW_DOODLER:
add $t8, $zero, $s2
sw $s5, -4($t8)
sw $s5, 4($t8)
sw $s5, -132($t8)
sw $s5, -128($t8)
sw $s5, -124($t8)
sw $s5, -256($t8)
jr $ra

# Platforms
DRAW_PLATFORM:
# Platform 1
add $t7, $zero, $s0
addi $t7, $t7, 260
sw $s4, 0($t7)
sw $s4, 4($t7)
sw $s4, 8($t7)
sw $s4, 12($t7)
sw $s4, 16($t7)
sw $s4, 20($t7)

# Platform 2
add $t7, $zero, $s0
addi $t7, $t7, 720
sw $s4, 0($t7)
sw $s4, 4($t7)
sw $s4, 8($t7)
sw $s4, 12($t7)
sw $s4, 16($t7)
sw $s4, 20($t7)

# Platform 3
add $t7, $zero, $s0
addi $t7, $t7, 1448
sw $s4, 0($t7)
sw $s4, 4($t7)
sw $s4, 8($t7)
sw $s4, 12($t7)
sw $s4, 16($t7)
sw $s4, 20($t7)

jr $ra

# =========================================================

Exit:
li $v0, 10 # terminate the program gracefully
syscall
