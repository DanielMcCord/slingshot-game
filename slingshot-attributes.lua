-----------------------------------------------------------------------------------------
--
-- slingshot-attributes.lua
--
-- Author:		Daniel McCord
-- Instructor:	Dave Parker
-- Course:		CSCI 79
-- Semester:	Spring 2019
-- Assignment:	Slingshot Game
--
-----------------------------------------------------------------------------------------

local glo = require( "globals" )

local s = {}
s.file = "slingshot.png"
s.scale = 1 / 16
s.width = 488 * s.scale
s.height = 1114 * s.scale
s.defaultX = glo.X_MIN + glo.WIDTH * 0.175
s.defaultY = glo.Y_MAX - s.height * 0.5

return s