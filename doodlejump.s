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
backgroundColour: .word 0xe6f7eb
doodlerColour: .word 0x0b2773

.text
lw $s0, displayAddress 			# $s0 stores the base address for display
lw $s1, displayMax			# $s1 stores the maximum display
lw $s2, doodlerX 			# $s2 stores the doodler's x
lw $s3, doodlerY			# $s3 stores the doodler's y
li $s4, 0x00000000			# $s4 stores whether the doodler is moving up or down
li $s5, 0x00000000			# $s5 stores the doodlers jump radius


li $s7, 0x0000000			# Game Over Condition
# Main =====================================================
main:
jal DRAW_BACKGROUND			# Draws Background
add $a2, $zero, $s2			# Checks X Position of Doodler
add $a3, $zero, $s3			# Checks Y Position of Doodler
jal DRAW_DOODLER			# Draws Doodler at (x,y)
jal DRAW_PLATFORM			# Draws Platform

START_LOOP:				# Starts the Game
lw $t1, 0xffff0000			# Checks Keyboard Input
beq $t1, 1, GAME_START_INPUT		# Jumps to check if Keyboard Input is S

j START_LOOP				# Otherwise goes back to Start Loop

# Game Loop ================================================
GAME_LOOP:				# MAIN GAME LOOP
beq $s7, 00000001, GAME_OVER		# Checks for game over (NOT NEEDED?)

li $v0, 32				# Sleeps Program
li $a0, 100
syscall

add $a2, $zero, $s2			# Checks X Position of Doodler
add $a3, $zero, $s3			# Checks Y Position of Doodler
jal REMOVE_DOODLER			# Removes Previous Doodler at (X,Y)

beq $s4, 1, MOVE_DOWN			# Checks if Doodler is Moving Up or Down
beq $s4, 0, MOVE_UP			# Checks if Doodler is Moving Up or Down

AFTER_MOVING_UP_OR_DOWN:		# After Doodler Moves Up or Down
beq $s3, 4096, GAME_OVER		# Checks if Doodler Hit Bottom
add $a2, $zero, $s2			# Gets new X of Doodler
add $a3, $zero, $s3			# Gets new Y of Doodler
jal DRAW_DOODLER			# DRAWS DOODLER IN NEW POSITION

li $v0, 32				# SLEEP
li $a0, 100
syscall

add $a2, $zero, $s2			# Removes Doodler Again
add $a3, $zero, $s3
jal REMOVE_DOODLER

lw $t1, 0xffff0000			# Checks for Keyboard Input
beq $t1, 1, KEYBOARD_INPUT

AFTER_KEYBOARD_INPUT:			# DRAWS DOODLER IN NEW POSITION
add $a2, $zero, $s2			
add $a3, $zero, $s3
jal DRAW_DOODLER

j GAME_LOOP				# REPEATS GAME LOOP

GAME_OVER:
j Exit


# Functions ================================================
GAME_START_INPUT:			# CHECKS IF 'S' WAS PRESSED TO START GAME
lw $t2, 0xffff0004
beq $t2, 115, GAME_LOOP
j START_LOOP

KEYBOARD_INPUT:				# Checks if 'A' or 'S' are pressed to move left or right
lw $t2, 0xffff0004
beq $t2, 97, MOVE_LEFT
beq $t2, 100, MOVE_RIGHT

MOVE_UP:
add $t1, $zero, $s3		# Adds the y coordinate to t1
addi $t1, $t1, -128		# Subtracts one row from the y coordinate
add $s3, $zero, $t1		# Saves this y coordinate back into s3
addi $s5, $s5, 1		# Adds 1 to the jump radius
beq $s5, 10, SWITCH_DOWN 	# Moves down if its jumped up 5
j AFTER_MOVING_UP_OR_DOWN

SWITCH_DOWN:
li $s4, 1			# Makes moving down True
j AFTER_MOVING_UP_OR_DOWN

MOVE_DOWN:			# Moves doodler down
add $t1, $zero, $s3
addi $t1, $t1, +128
add $s3, $zero, $t1
addi $s5, $s5, -1
beq $s5, $zero, SWITCH_UP
j AFTER_MOVING_UP_OR_DOWN

SWITCH_UP:
li $s4, 0			# Makes moving down False
j AFTER_MOVING_UP_OR_DOWN

MOVE_LEFT:			# Moves doodler left
add $t1, $zero, $s2
addi $t1, $t1, -8
add $s2, $zero, $t1
j AFTER_KEYBOARD_INPUT

MOVE_RIGHT:			# Moves doodler right
add $t1, $zero, $s2
addi $t1, $t1, 8
add $s2, $zero, $t1
j AFTER_KEYBOARD_INPUT

# Background
DRAW_BACKGROUND:
add $t9, $zero, $s0		# $t9 stores the value of the base address
LOOP:				# For loop through each pixel
lw $t8, backgroundColour	# Stores the background colour in t8
sw $t8, 0($t9)			# Overwriting the colour at address $t9
beq $t9, $s1, END		# Checking if $t9 reached the max
UPDATE:
addi $t9, $t9, 4
j LOOP
END: 
jr $ra

# Doodler (x,y)
DRAW_DOODLER:
add $t1, $s0, $a2		# Adds the x coordinate to t1
add $t2, $t1, $a3		# Adds the y coordinate to t2
lw $t3, doodlerColour		# Adds the doodler colour to t3
sw $t3, 0($t2)
jr $ra

# Removes Doodler (x,y)
REMOVE_DOODLER:
add $t1, $s0, $a2		# Adds the x coordinate to t1
add $t2, $t1, $a3		# Adds the y coordinate to t2
lw $t3, backgroundColour	# adds the background colour to t3
sw $t3, 0($t2)
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
li $v0, 10 			# terminate the program gracefully
syscall
