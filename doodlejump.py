

# Game logic for Doodle Jump
var doodlerX
var doodlerY
var displayAddress
var displayMax
var backgroundColour
var platformColour
var doodlerColour
var GameOver = 0


drawdoodler(doodlerX, doodlerY)           # y=1
drawbackground()
drawplatforms()

while GameOver == 0:
def getKeyboardInput(key):
    if key == "j": 
        updateleft()
    if key == "k":
        updateright()
    if key == None:
        update()


def drawbackground()
    # omitted

def drawdoodler(doodlerX, doodlerY)
    # initial position

# def drawplatforms()
#     # draw three random platforms

# def updateleft():
#     doodlerX -= 1
#     drawdoodler(doodlerX, doodlerY)