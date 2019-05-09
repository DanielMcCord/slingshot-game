-----------------------------------------------------------------------------------------
--
-- globals.lua
--
-- Author:		Daniel McCord
-- Instructor:	Dave Parker
-- Course:		CSCI 79
-- Semester:	Spring 2019
-- Assignment:	Slingshot Game
--
-----------------------------------------------------------------------------------------

local g = {}

g.WIDTH = display.actualContentWidth -- the actual width of the display
g.HEIGHT = display.actualContentHeight -- the actual height of the display
g.X_MIN = display.screenOriginX -- the left edge of the display
g.Y_MIN = display.screenOriginY -- the top edge of the display
g.X_MAX = g.X_MIN + g.WIDTH -- the right edge of the display
g.Y_MAX = g.Y_MIN + g.HEIGHT -- the bottom edge of the display
g.X_CENTER = (g.X_MIN + g.X_MAX) / 2 -- the center of the display (horozontal axis)
g.Y_CENTER = (g.Y_MIN + g.Y_MAX) / 2 -- the center of the display (vertical axis)
g.MESSAGE_ON_WIN = "You win!" -- message to display on screen when player wins
g.MESSAGE_ON_LOSE = "You lost." -- message to display on screen wehn player loses

return g