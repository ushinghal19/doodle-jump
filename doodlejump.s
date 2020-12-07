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
doodler2X: .word 56
doodler2Y: .word 3712
doodler3X: .word 64
doodler3Y: .word 3712

score: .word 0
 
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
# Main =========================================================================================
main:
lw $s0, displayAddress 			# $s0 stores the base address for display
lw $s1, displayMax			# $s1 stores the maximum display
lw $s2, doodlerX 			# $s2 stores the doodler's x
lw $s3, doodlerY			# $s3 stores the doodler's y
li $s4, 0x00000000			# $s4 stores whether the doodler is moving up or down
li $s5, 0x00000000			# $s5 stores the doodlers jump radius

addi $t9, $zero, 56
addi $t8, $zero, 3712
addi $t7, $zero, 64

sw $t9, doodler2X
sw $t8, doodler2Y
sw $t7, doodler3X
sw $t8, doodler3Y

sw $zero, score

li $s7, 0x0000000			# Game Over Condition

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

lw $s6, score

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

jal DRAW_PLATFORM_1
jal DRAW_PLATFORM_2
jal DRAW_PLATFORM_3
jal DRAW_PLATFORM_4
jal DRAW_PLATFORM_5

li $v0, 32				# SLEEP
li $a0, 100
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
jal DRAW_FINISH_SCREEN

AFTER_DRAWING_FINISH_SCREEN:
j GAME_RESTART_INPUT


j Exit

# Functions ====================================================================================
GAME_START_INPUT:			# CHECKS IF 'S' WAS PRESSED TO START GAME
lw $t2, 0xffff0004
beq $t2, 115, GAME_LOOP
j START_LOOP

GAME_RESTART_INPUT:
lw $t2, 0xffff0004
beq $t2, 115, main
j AFTER_DRAWING_FINISH_SCREEN

KEYBOARD_INPUT:				# Checks if 'A' or 'S' are pressed to move left or right
lw $t2, 0xffff0004
beq $t2, 97, MOVE_LEFT
beq $t2, 100, MOVE_RIGHT
j AFTER_KEYBOARD_INPUT

#=============================================
MOVE_PLATFORMS_DOWN:
jal DRAW_BACKGROUND
#jal DRAW_DOODLER
 
lw $t1, platform_1Y
addi $t1, $t1, 128
sw $t1, platform_1Y

lw $t2, platform_2Y
addi $t2, $t2, 128
sw $t2, platform_2Y

lw $t3, platform_3Y
addi $t3, $t3, 128
sw $t3, platform_3Y

lw $t4, platform_4Y
addi $t4, $t4, 128
sw $t4, platform_4Y

lw $t5, platform_5Y
addi $t5, $t5, 128
sw $t5, platform_5Y

beq $t1, 4096, MOVE_PLATFORM_1_TO_TOP
beq $t2, 4096, MOVE_PLATFORM_2_TO_TOP
beq $t3, 4096, MOVE_PLATFORM_3_TO_TOP
beq $t4, 4096, MOVE_PLATFORM_4_TO_TOP
beq $t5, 4096, MOVE_PLATFORM_5_TO_TOP
jal DRAW_PLATFORM_1
jal DRAW_PLATFORM_2
jal DRAW_PLATFORM_3
jal DRAW_PLATFORM_4
jal DRAW_PLATFORM_5

j BACK_TO_UP

#=============================================

MOVE_PLATFORM_1_TO_TOP:
lw $t1, platform_1Y
addi $t1, $t1, -3968
sw $t1, platform_1Y
jal RANDOM_X1
jal DRAW_PLATFORM_1
j BACK_TO_UP

MOVE_PLATFORM_2_TO_TOP:
lw $t1, platform_2Y
addi $t1, $t1, -3968
sw $t1, platform_2Y
jal RANDOM_X2
jal DRAW_PLATFORM_2
j BACK_TO_UP

MOVE_PLATFORM_3_TO_TOP:
lw $t1, platform_3Y
addi $t1, $t1, -3968
sw $t1, platform_3Y
jal RANDOM_X3
jal DRAW_PLATFORM_3
j BACK_TO_UP

MOVE_PLATFORM_4_TO_TOP:
lw $t1, platform_4Y
addi $t1, $t1, -3968
sw $t1, platform_4Y
jal RANDOM_X4
jal DRAW_PLATFORM_4
j BACK_TO_UP

MOVE_PLATFORM_5_TO_TOP:
lw $t1, platform_5Y
addi $t1, $t1, -3968
sw $t1, platform_5Y
jal RANDOM_X5
jal DRAW_PLATFORM_5
j BACK_TO_UP

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

lw $t2, doodler2Y
lw $t3, doodler3Y

addi $t2, $t2, -128
addi $t3, $t3, -128

sw $t2, doodler2Y
sw $t3, doodler3Y

addi $s5, $s5, 1
j AFTER_MOVING_UP_OR_DOWN

MOVE_UP:
add $t1, $zero, $s3		# Adds the y coordinate to t1
addi $t1, $t1, -128		# Subtracts one row from the y coordinate

lw $t2, doodler2Y
lw $t3, doodler3Y

addi $t2, $t2, -128
addi $t3, $t3, -128

sw $t2, doodler2Y
sw $t3, doodler3Y

add $s3, $zero, $t1		# Saves this y coordinate back into s3
addi $s5, $s5, 1		# Adds 1 to the jump radius
lw $t9, score
addi $t9, $t9, 1
sw $t9, score

jal MOVE_PLATFORMS_DOWN

BACK_TO_UP:
bge $s5, 8, SWITCH_DOWN 	# Moves down if its jumped up 5
j AFTER_MOVING_UP_OR_DOWN

SWITCH_DOWN:
li $s4, 1			# Makes moving down True
j AFTER_MOVING_UP_OR_DOWN

MOVE_DOWN:			# Moves doodler down
add $t1, $zero, $s3
addi $t1, $t1, +128
add $s3, $zero, $t1
addi $s5, $s5, -1

lw $t2, doodler2Y
lw $t3, doodler3Y

addi $t2, $t2, 128
addi $t3, $t3, 128

sw $t2, doodler2Y
sw $t3, doodler3Y

# beq $s5, $zero, SWITCH_UP
j AFTER_MOVING_UP_OR_DOWN

SWITCH_UP:
li $s4, 0			# Makes moving down False
j MOVE_UP

MOVE_LEFT:			# Moves doodler left
add $t1, $zero, $s2
addi $t1, $t1, -8
add $s2, $zero, $t1

lw $t2, doodler2X
lw $t3, doodler3X

addi $t2, $t2, -8
addi $t3, $t3, -8

sw $t2, doodler2X
sw $t3, doodler3X

j AFTER_KEYBOARD_INPUT

MOVE_RIGHT:			# Moves doodler right
add $t1, $zero, $s2
addi $t1, $t1, 8
add $s2, $zero, $t1

lw $t2, doodler2X
lw $t3, doodler3X

addi $t2, $t2, 8
addi $t3, $t3, 8

sw $t2, doodler2X
sw $t3, doodler3X

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

lw $t9, doodler2X
lw $t8, doodler2Y
add $t7, $s0, $t9
add $t7, $t7, $t8

lw $t6, doodler3X
lw $t5, doodler3Y
add $t4, $s0, $t6
add $t4, $t4, $t5

sw $t3, 0($t2)
sw $t3, 0($t7)
sw $t3, 0($t4)

jr $ra

# Removes Doodler (x,y)
REMOVE_DOODLER:
add $t1, $s0, $a2		# Adds the x coordinate to t1
add $t1, $t1, $a3		# Adds the y coordinate to t2
lw $t2, backgroundColour	# adds the background colour to t3
sw $t2, 0($t1)

lw $t9, doodler2X
lw $t8, doodler3X
lw $t7, doodler2Y
lw $t6, doodler3Y

add $t5, $s0, $t9
add $t5, $t5, $t7
add $t4, $s0, $t8
add $t4, $t4, $t6

sw $t2, 0($t5)
sw $t2, 0($t4)
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

DRAW_FINISH_SCREEN:
add $t9, $zero, $s0		# $t9 stores the value of the base address
LOOP1:				# For loop through each pixel
add $t8, $zero, $zero		# Stores black in t8
sw $t8, 0($t9)			# Overwriting the colour at address $t9
beq $t9, $s1, END1		# Checking if $t9 reached the max
UPDATE1:
addi $t9, $t9, 4
j LOOP1
END1: 
j DRAW_RESTART

DRAW_RESTART:
jal DRAW_PLATFORM_1
jal DRAW_PLATFORM_2
jal DRAW_PLATFORM_3
jal DRAW_PLATFORM_4
jal DRAW_PLATFORM_5

add $t9, $zero, $s0
addi $t8, $zero, 0xffffff

#G1===================
sw $t8, 396($t9)
sw $t8, 400($t9)
sw $t8, 404($t9)
sw $t8, 408($t9)
sw $t8, 412($t9)
sw $t8, 416($t9)
sw $t8, 420($t9)

sw $t8, 524($t9)
sw $t8, 652($t9)
sw $t8, 780($t9)
sw $t8, 908($t9)
sw $t8, 1036($t9)
sw $t8, 1164($t9)
sw $t8, 1292($t9)
sw $t8, 1420($t9)

sw $t8, 1420($t9)
sw $t8, 1424($t9)
sw $t8, 1428($t9)
sw $t8, 1432($t9)
sw $t8, 1436($t9)
sw $t8, 1440($t9)
sw $t8, 1444($t9)

sw $t8, 1316($t9)
sw $t8, 1188($t9)
sw $t8, 1060($t9)
sw $t8, 1056($t9)
sw $t8, 1052($t9)

#G2==================
sw $t8, 436($t9)
sw $t8, 440($t9)
sw $t8, 444($t9)
sw $t8, 448($t9)
sw $t8, 452($t9)
sw $t8, 456($t9)
sw $t8, 460($t9)

sw $t8, 564($t9)
sw $t8, 692($t9)
sw $t8, 820($t9)
sw $t8, 948($t9)
sw $t8, 1076($t9)
sw $t8, 1204($t9)
sw $t8, 1204($t9)
sw $t8, 1332($t9)
sw $t8, 1460($t9)

sw $t8, 1464($t9)
sw $t8, 1468($t9)
sw $t8, 1472($t9)
sw $t8, 1476($t9)
sw $t8, 1480($t9)
sw $t8, 1484($t9)

sw $t8, 1356($t9)
sw $t8, 1228($t9)
sw $t8, 1100($t9)
sw $t8, 1096($t9)
sw $t8, 1092($t9)

# P
sw $t8, 3340($t9)
sw $t8, 3468($t9)
sw $t8, 3596($t9)
sw $t8, 3724($t9)
sw $t8, 3852($t9)

sw $t8, 3344($t9)
sw $t8, 3348($t9)
sw $t8, 3476($t9)
sw $t8, 3604($t9)
sw $t8, 3600($t9)

# R
sw $t8, 3356($t9)
sw $t8, 3484($t9)
sw $t8, 3612($t9)
sw $t8, 3740($t9)
sw $t8, 3868($t9)

sw $t8, 3360($t9)
sw $t8, 3364($t9)
sw $t8, 3492($t9)
sw $t8, 3620($t9)
sw $t8, 3616($t9)

sw $t8, 3744($t9)
sw $t8, 3876($t9)

# E
sw $t8, 3372($t9)
sw $t8, 3500($t9)
sw $t8, 3628($t9)
sw $t8, 3756($t9)
sw $t8, 3884($t9)

sw $t8, 3376($t9)
sw $t8, 3380($t9)
sw $t8, 3636($t9)
sw $t8, 3632($t9)

sw $t8, 3888($t9)
sw $t8, 3892($t9)

# S
sw $t8, 3388($t9)
sw $t8, 3516($t9)
sw $t8, 3644($t9)
sw $t8, 3780($t9)
sw $t8, 3900($t9)

sw $t8, 3392($t9)
sw $t8, 3396($t9)
sw $t8, 3652($t9)
sw $t8, 3648($t9)

sw $t8, 3904($t9)
sw $t8, 3908($t9)

# S
sw $t8, 3404($t9)
sw $t8, 3532($t9)
sw $t8, 3660($t9)
sw $t8, 3796($t9)
sw $t8, 3916($t9)

sw $t8, 3408($t9)
sw $t8, 3412($t9)
sw $t8, 3668($t9)
sw $t8, 3664($t9)

sw $t8, 3920($t9)
sw $t8, 3924($t9)

# :
sw $t8, 3804($t9)
sw $t8, 3548($t9)

# S
sw $t8, 3432($t9)
sw $t8, 3560($t9)
sw $t8, 3688($t9)
sw $t8, 3824($t9)
sw $t8, 3944($t9)

sw $t8, 3436($t9)
sw $t8, 3440($t9)
sw $t8, 3696($t9)
sw $t8, 3692($t9)

sw $t8, 3948($t9)
sw $t8, 3952($t9)

j DRAW_SCORE

AFTER_DRAWING_SCORE:
j AFTER_DRAWING_FINISH_SCREEN

DRAW_SCORE:
add $t1, $zero, $zero

rem $t2, $s6, 10
sub $t3, $s6, $t2
div $t3, $t3, 10

rem $t4, $t3, 10
sub $t3, $t3, $t4
div $t3, $t3, 10

add $t6, $zero, $t5

beq $t2, 0, ZERO_1
beq $t2, 1, ONE_1
beq $t2, 2, TWO_1
beq $t2, 3, THREE_1
beq $t2, 4, FOUR_1
beq $t2, 5, FIVE_1
beq $t2, 6, SIX_1
beq $t2, 7, SEVEN_1
beq $t2, 8, EIGHT_1
beq $t2, 9, NINE_1

AFTER_FIRST_DIGIT:
j AFTER_DRAWING_SCORE


ZERO_1:
add $t9, $zero, $s0
addi $t8, $zero, 0xffffff

sw $t8, 2060($t9)
sw $t8, 2188($t9)
sw $t8, 2316($t9)
sw $t8, 2444($t9)
sw $t8, 2572($t9)
sw $t8, 2700($t9)
sw $t8, 2828($t9)


j AFTER_FIRST_DIGIT

ONE_1:
add $t9, $zero, $s0
addi $t8, $zero, 0xffffff

sw $t8, 2060($t9)
sw $t8, 2188($t9)
sw $t8, 2316($t9)
sw $t8, 2444($t9)
sw $t8, 2572($t9)
sw $t8, 2700($t9)
sw $t8, 2828($t9)

j AFTER_FIRST_DIGIT

TWO_1:
add $t9, $zero, $s0
addi $t8, $zero, 0xffffff


sw $t8, 2060($t9)
sw $t8, 2188($t9)
sw $t8, 2316($t9)
sw $t8, 2444($t9)
sw $t8, 2572($t9)
sw $t8, 2700($t9)
sw $t8, 2828($t9)

j AFTER_FIRST_DIGIT

THREE_1:
add $t9, $zero, $s0
addi $t8, $zero, 0xffffff

sw $t8, 2060($t9)
sw $t8, 2188($t9)
sw $t8, 2316($t9)
sw $t8, 2444($t9)
sw $t8, 2572($t9)
sw $t8, 2700($t9)
sw $t8, 2828($t9)
j AFTER_FIRST_DIGIT

FOUR_1:
add $t9, $zero, $s0
addi $t8, $zero, 0xffffff
sw $t8, 2060($t9)
sw $t8, 2188($t9)
sw $t8, 2316($t9)
sw $t8, 2444($t9)
sw $t8, 2572($t9)
sw $t8, 2700($t9)
sw $t8, 2828($t9)

j AFTER_FIRST_DIGIT

FIVE_1:
add $t9, $zero, $s0
addi $t8, $zero, 0xffffff

sw $t8, 2060($t9)
sw $t8, 2188($t9)
sw $t8, 2316($t9)
sw $t8, 2444($t9)
sw $t8, 2572($t9)
sw $t8, 2700($t9)
sw $t8, 2828($t9)
j AFTER_FIRST_DIGIT

SIX_1:
add $t9, $zero, $s0
addi $t8, $zero, 0xffffff

sw $t8, 2060($t9)
sw $t8, 2188($t9)
sw $t8, 2316($t9)
sw $t8, 2444($t9)
sw $t8, 2572($t9)
sw $t8, 2700($t9)
sw $t8, 2828($t9)
j AFTER_FIRST_DIGIT

SEVEN_1:
add $t9, $zero, $s0
addi $t8, $zero, 0xffffff

sw $t8, 2060($t9)
sw $t8, 2188($t9)
sw $t8, 2316($t9)
sw $t8, 2444($t9)
sw $t8, 2572($t9)
sw $t8, 2700($t9)
sw $t8, 2828($t9)

j AFTER_FIRST_DIGIT

EIGHT_1:
add $t9, $zero, $s0
addi $t8, $zero, 0xffffff

sw $t8, 2060($t9)
sw $t8, 2188($t9)
sw $t8, 2316($t9)
sw $t8, 2444($t9)
sw $t8, 2572($t9)
sw $t8, 2700($t9)
sw $t8, 2828($t9)

j AFTER_FIRST_DIGIT

NINE_1:
add $t9, $zero, $s0
addi $t8, $zero, 0xffffff

sw $t8, 2060($t9)
sw $t8, 2188($t9)
sw $t8, 2316($t9)
sw $t8, 2444($t9)
sw $t8, 2572($t9)
sw $t8, 2700($t9)
sw $t8, 2828($t9)

j AFTER_FIRST_DIGIT



# ==============================================================================================

Exit:
li $v0, 10 			# terminate the program gracefully
syscall
