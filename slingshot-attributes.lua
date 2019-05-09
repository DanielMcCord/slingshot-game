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
s.scale = 1 / 13 -- set between 1/7 and 1/15 for best results
s.width = 488 * s.scale
s.height = 1114 * s.scale
s.defaultX = glo.X_MIN + glo.WIDTH * 0.175
s.defaultY = glo.Y_MAX - s.height * 0.5
s.nockHeight = .75
s.releaseDuration = 100

return s