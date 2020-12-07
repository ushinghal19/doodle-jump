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
platformColour: .word 0x8f1822
platform_1X: .word 0
platform_1Y: .word 3584
platform_2X: .word 0
platform_2Y: .word 2816
platform_3X: .word 0
platform_3Y: .word 2048
platform_4X: .word 0
platform_4Y: .word 1280
platform_5X: .word 0
platform_5Y: .word 512

.text
lw $s0, displayAddress 			# $s0 stores the base address for display
lw $s1, displayMax			# $s1 stores the maximum display
lw $s2, doodlerX 			# $s2 stores the doodler's x
lw $s3, doodlerY			# $s3 stores the doodler's y
li $s4, 0x00000000			# $s4 stores whether the doodler is moving up or down
li $s5, 0x00000000			# $s5 stores the doodlers jump radius


li $s7, 0x0000000			# Game Over Condition
# Main =========================================================================================
main:
jal DRAW_BACKGROUND			# Draws Background
add $a2, $zero, $s2			# Checks X Position of Doodler
add $a3, $zero, $s3			# Checks Y Position of Doodler
jal DRAW_DOODLER			# Draws Doodler at (x,y)

jal RANDOM_X1
jal DRAW_PLATFORM_1			# Draws Platform

jal RANDOM_X2
jal DRAW_PLATFORM_2			# Draws Platform

jal RANDOM_X3
jal DRAW_PLATFORM_3			# Draws Platform

jal RANDOM_X4
jal DRAW_PLATFORM_4			# Draws Platform

jal RANDOM_X5
jal DRAW_PLATFORM_5			# Draws Platform


START_LOOP:				# Starts the Game
lw $t1, 0xffff0000			# Checks Keyboard Input
beq $t1, 1, GAME_START_INPUT		# Jumps to check if Keyboard Input is S

j START_LOOP				# Otherwise goes back to Start Loop

# Game Loop ====================================================================================
GAME_LOOP:				# MAIN GAME LOOP
li $v0, 32				# Sleeps Program
li $a0, 10
syscall

add $a2, $zero, $s2			# Checks X Position of Doodler
add $a3, $zero, $s3			# Checks Y Position of Doodler
jal REMOVE_DOODLER			# Removes Previous Doodler at (X,Y)

beq $s4, 1, MOVE_DOWN			# Checks if Doodler is Moving Up or Down
beq $s4, 0, MOVE_UP			# Checks if Doodler is Moving Up or Down

AFTER_MOVING_UP_OR_DOWN:		# After Doodler Moves Up or Down
beq $s3, 4096, GAME_OVER		# Checks if Doodler Hit Bottom

jal CHECK_COLLISION

add $a2, $zero, $s2			# Gets new X of Doodler
add $a3, $zero, $s3			# Gets new Y of Doodler
jal DRAW_DOODLER			# DRAWS DOODLER IN NEW POSITION

li $v0, 32				# SLEEP
li $a0, 75
syscall

add $a2, $zero, $s2			# Removes Doodler Again
add $a3, $zero, $s3
jal REMOVE_DOODLER

lw $t1, 0xffff0000			# Checks for Keyboard Input
beq $t1, 1, KEYBOARD_INPUT

AFTER_KEYBOARD_INPUT:
jal CHECK_COLLISION			
add $a2, $zero, $s2			# DRAWS DOODLER IN NEW POSITION
add $a3, $zero, $s3
jal DRAW_DOODLER

j GAME_LOOP				# REPEATS GAME LOOP

GAME_OVER:
add $t9, $zero, $s0		# $t9 stores the value of the base address
LOOP1:				# For loop through each pixel
add $t8, $zero, $zero		# Stores black in t8
sw $t8, 0($t9)			# Overwriting the colour at address $t9
beq $t9, $s1, END1		# Checking if $t9 reached the max
UPDATE1:
addi $t9, $t9, 4
j LOOP1
END1: 
j Exit


# Functions ====================================================================================
GAME_START_INPUT:			# CHECKS IF 'S' WAS PRESSED TO START GAME
lw $t2, 0xffff0004
beq $t2, 115, GAME_LOOP
j START_LOOP

KEYBOARD_INPUT:				# Checks if 'A' or 'S' are pressed to move left or right
lw $t2, 0xffff0004
beq $t2, 97, MOVE_LEFT
beq $t2, 100, MOVE_RIGHT
j AFTER_KEYBOARD_INPUT

#=============================================
MOVE_PLATFORMS_DOWN:
jal DRAW_BACKGROUND
#jal DRAW_DOODLER

AFTER_FIVE_TO_TOP:
lw $t1, platform_1Y
addi $t1, $t1, 128
sw $t1, platform_1Y
beq $t1, 4096, MOVE_PLATFORM_1_TO_TOP
jal DRAW_PLATFORM_1

AFTER_ONE_TO_TOP:
lw $t1, platform_2Y
addi $t1, $t1, 128
sw $t1, platform_2Y
beq $t1, 4096, MOVE_PLATFORM_2_TO_TOP
jal DRAW_PLATFORM_2

AFTER_TWO_TO_TOP:
lw $t1, platform_3Y
addi $t1, $t1, 128
sw $t1, platform_3Y
beq $t1, 4096, MOVE_PLATFORM_3_TO_TOP
jal DRAW_PLATFORM_3

AFTER_THREE_TO_TOP:
lw $t1, platform_4Y
addi $t1, $t1, 128
sw $t1, platform_4Y
beq $t1, 4096, MOVE_PLATFORM_4_TO_TOP
jal DRAW_PLATFORM_4

AFTER_FOUR_TO_TOP:
lw $t1, platform_5Y
addi $t1, $t1, 128
sw $t1, platform_5Y
beq $t1, 4096, MOVE_PLATFORM_5_TO_TOP
jal DRAW_PLATFORM_5

j BACK_TO_UP

#=============================================

MOVE_PLATFORM_1_TO_TOP:
lw $t1, platform_1Y
addi $t1, $t1, -4096
sw $t1, platform_1Y
j AFTER_ONE_TO_TOP

MOVE_PLATFORM_2_TO_TOP:
lw $t1, platform_2Y
addi $t1, $t1, -4096
sw $t1, platform_2Y
j AFTER_TWO_TO_TOP

MOVE_PLATFORM_3_TO_TOP:
lw $t1, platform_3Y
addi $t1, $t1, -4096
sw $t1, platform_3Y
j AFTER_THREE_TO_TOP

MOVE_PLATFORM_4_TO_TOP:
lw $t1, platform_4Y
addi $t1, $t1, -4096
sw $t1, platform_4Y
j AFTER_FOUR_TO_TOP

MOVE_PLATFORM_5_TO_TOP:
lw $t1, platform_5Y
addi $t1, $t1, -4096
sw $t1, platform_5Y
j AFTER_FIVE_TO_TOP

CHECK_COLLISION:
add $t1, $zero, $s0			# CHECKING FOR COLLISION
add $t1, $t1, $s2			
add $t1, $t1, $s3			# t1 stores the pixel that the doodler is at.
lw $t2, platformColour
lw $t3, 0($t1)
beq $t2, $t3, COLLISION			# Checking if the pixel is at a collision
jr $ra

COLLISION:
beq $s4, 1, COLLISION_DOWN
beq $s4, 0, COLLISION_UP

COLLISION_DOWN:
add $s5, $zero, $zero
j SWITCH_UP

COLLISION_UP:
addi $s3, $s3, -128
addi $s5, $s5, 1
j AFTER_MOVING_UP_OR_DOWN

MOVE_UP:
add $t1, $zero, $s3		# Adds the y coordinate to t1
addi $t1, $t1, -128		# Subtracts one row from the y coordinate
add $s3, $zero, $t1		# Saves this y coordinate back into s3
addi $s5, $s5, 1		# Adds 1 to the jump radius

jal MOVE_PLATFORMS_DOWN

BACK_TO_UP:
beq $s5, 5, SWITCH_DOWN 	# Moves down if its jumped up 5
j AFTER_MOVING_UP_OR_DOWN

SWITCH_DOWN:
li $s4, 1			# Makes moving down True
j AFTER_MOVING_UP_OR_DOWN

MOVE_DOWN:			# Moves doodler down
add $t1, $zero, $s3
addi $t1, $t1, +128
add $s3, $zero, $t1
addi $s5, $s5, -1
# beq $s5, $zero, SWITCH_UP
j AFTER_MOVING_UP_OR_DOWN

SWITCH_UP:
li $s4, 0			# Makes moving down False
j MOVE_UP

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


RANDOM_X1:
li $v0, 42			# Random # (X COORD)
li $a0, 0
li $a1, 25
syscall
addi $a0, $a0, 3
mul $a0, $a0, 4
sw $a0, platform_1X
jr $ra

RANDOM_X2:
li $v0, 42			# Random # (X COORD)
li $a0, 0
li $a1, 25
syscall
addi $a0, $a0, 3
mul $a0, $a0, 4
sw $a0, platform_2X
jr $ra

RANDOM_X3:
li $v0, 42			# Random # (X COORD)
li $a0, 0
li $a1, 25
syscall
addi $a0, $a0, 3
mul $a0, $a0, 4
sw $a0, platform_3X
jr $ra

RANDOM_X4:
li $v0, 42			# Random # (X COORD)
li $a0, 0
li $a1, 25
syscall
addi $a0, $a0, 3
mul $a0, $a0, 4
sw $a0, platform_4X
jr $ra

RANDOM_X5:
li $v0, 42			# Random # (X COORD)
li $a0, 0
li $a1, 25
syscall
addi $a0, $a0, 3
mul $a0, $a0, 4
sw $a0, platform_5X
jr $ra


# Platforms
DRAW_PLATFORM_1:
lw $t1, platformColour		# Gets platform colour into t1
add $t2, $zero, $s0		# Display address into t2
lw $t9, platform_1X
lw $t8, platform_1Y
add $t2, $t2, $t9		# add x coord into t2
add $t2, $t2, $t8		# add y coord into t2

sw $t1, 0($t2)
sw $t1, -4($t2)
sw $t1, -8($t2)
sw $t1, -12($t2)
sw $t1, 4($t2)
sw $t1, 8($t2)
sw $t1, 12($t2)
jr $ra

DRAW_PLATFORM_2:
lw $t1, platformColour		# Gets platform colour into t1
add $t2, $zero, $s0		# Display address into t2
lw $t9, platform_2X
lw $t8, platform_2Y
add $t2, $t2, $t9		# add x coord into t2
add $t2, $t2, $t8		# add y coord into t2

sw $t1, 0($t2)
sw $t1, -4($t2)
sw $t1, -8($t2)
sw $t1, -12($t2)
sw $t1, 4($t2)
sw $t1, 8($t2)
sw $t1, 12($t2)
jr $ra

DRAW_PLATFORM_3:
lw $t1, platformColour		# Gets platform colour into t1
add $t2, $zero, $s0		# Display address into t2
lw $t9, platform_3X
lw $t8, platform_3Y
add $t2, $t2, $t9		# add x coord into t2
add $t2, $t2, $t8		# add y coord into t2

sw $t1, 0($t2)
sw $t1, -4($t2)
sw $t1, -8($t2)
sw $t1, -12($t2)
sw $t1, 4($t2)
sw $t1, 8($t2)
sw $t1, 12($t2)
jr $ra

DRAW_PLATFORM_4:
lw $t1, platformColour		# Gets platform colour into t1
add $t2, $zero, $s0		# Display address into t2
lw $t9, platform_4X
lw $t8, platform_4Y
add $t2, $t2, $t9		# add x coord into t2
add $t2, $t2, $t8		# add y coord into t2

sw $t1, 0($t2)
sw $t1, -4($t2)
sw $t1, -8($t2)
sw $t1, -12($t2)
sw $t1, 4($t2)
sw $t1, 8($t2)
sw $t1, 12($t2)
jr $ra

DRAW_PLATFORM_5:
lw $t1, platformColour		# Gets platform colour into t1
add $t2, $zero, $s0		# Display address into t2
lw $t9, platform_5X
lw $t8, platform_5Y
add $t2, $t2, $t9		# add x coord into t2
add $t2, $t2, $t8		# add y coord into t2

sw $t1, 0($t2)
sw $t1, -4($t2)
sw $t1, -8($t2)
sw $t1, -12($t2)
sw $t1, 4($t2)
sw $t1, 8($t2)
sw $t1, 12($t2)
jr $ra

# ==============================================================================================

Exit:
li $v0, 10 			# terminate the program gracefully
syscall
