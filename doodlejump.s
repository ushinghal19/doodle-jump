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
doodlerX: .word 0x0000003C
doodlerY: .word 0x00000F00

.text
lw $s0, displayAddress 	# $s0 stores the base address for display
lw $s1, displayMax	# $s1 stores the maximum display
lw $s2, doodlerX 	# $s2 stores the doodler's x
lw $s3, doodlerY	# $s3 stores the doodler's y
li $s4, 0xe6f7eb	# $s4 stores the background colour
li $s5, 0x821012	# $s5 stores the platform colour
li $s6, 0x0b2773	# $s6 stores the doodler colour

li $s7, 0x0000000	# Game Over Condition
# Main =====================================================
main:
jal DRAW_BACKGROUND	# Draws Background
add $a2, $zero, $s2
add $a3, $zero, $s3
jal DRAW_DOODLER
jal DRAW_PLATFORM
jal GAME_LOOP

j Exit

# Game Loop ================================================
GAME_LOOP:
beq $s7, 00000001, GAME_OVER

li $v0, 32
li $a0, 100
syscall

add $a2, $zero, $s2
add $a3, $zero, $s3
jal REMOVE_DOODLER

lw $t1, 0xffff0000
beq $t1, 1, KEYBOARD_INPUT

RETURN_HERE:
add $a2, $zero, $s2
add $a3, $zero, $s3
jal DRAW_DOODLER

j GAME_LOOP

GAME_OVER:
jr $ra


# Functions ================================================
KEYBOARD_INPUT:
lw $t2, 0xffff0004
beq $t2, 97, MOVE_LEFT
beq $t2, 100, MOVE_RIGHT

MOVE_LEFT:
add $t1, $zero, $s2
addi $t1, $t1, -4
add $s2, $zero, $t1
j RETURN_HERE

MOVE_RIGHT:
add $t1, $zero, $s2
addi $t1, $t1, +4
add $s2, $zero, $t1
j RETURN_HERE

# Background
DRAW_BACKGROUND:
add $t9, $zero, $s0	# $t9 stores the value of the base address
LOOP:			# For loop through each pixel
sw $s4, 0($t9)		# Overwriting the colour at address $t9
beq $t9, $s1, END	# Checking if $t9 reached the max
UPDATE:
addi $t9, $t9, 4
j LOOP
END: 
jr $ra

# Doodler (x,y)
DRAW_DOODLER:
add $t1, $s0, $a2
add $t2, $t1, $a3
sw $s6, 0($t2)
jr $ra

# Removes Doodler (x,y)
REMOVE_DOODLER:
add $t1, $s0, $a2
add $t2, $t1, $a3
sw $s4, 0($t2)
jr $ra

# Platforms
DRAW_PLATFORM:
# Platform 1
add $t7, $zero, $s0
addi $t7, $t7, 260
sw $s5, 0($t7)
sw $s5, 4($t7)
sw $s5, 8($t7)
sw $s5, 12($t7)
sw $s5, 16($t7)
sw $s5, 20($t7)
jr $ra


# =========================================================

Exit:
li $v0, 10 # terminate the program gracefully
syscall
