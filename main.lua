-----------------------------------------------------------------------------------------
--
-- main.lua
--
-- Author:		Daniel McCord
-- Instructor:	Dave Parker
-- Course:		CSCI 79
-- Semester:	Spring 2019
-- Assignment:	Slingshot Game
--
-----------------------------------------------------------------------------------------

--[[
Grading

	[TODO](10) Display of slingshot
	[TODO](10) Display of castle on platform with target object inside
	[TODO](10) Display tracking of projectile as user drags
	[TODO](10) Physics of projectile in flight
	[TODO](10) Physics of projectile knocking over castle parts
	[TODO](10) At least two castle parts are connected by a joint
	[TODO](10) Display of projectile causing damage to castle parts over repeated hits
	[TODO](10) Castle parts explode/disappear after enough hits (individually)
	[TODO](10) User wins if the target object is hit,
		but loses if runs out of projectiles
	[TODO](10) Good comments, indentation, and function structure

 Extra Credit:

	(0-5) Interesting/creative coolness in any area,
		above and beyond the minimum requirements above.

--]]

local glo = require( "globals" )

-- Variables
local projectiles -- table for all the player's projectiles
local gameEnded -- text that is generated when the game ends

-- Functions

local endGame
local push
local pop
local onProjectileEnded
local newFrame
local init

-- Displays game-over message when game is lost
function endGame( message )
	gameEnded = display.newText{
		text = message,
		x = glo.WIDTH / 2,
		y = glo.HEIGHT / 2,
		font = native.systemFontBold,
		align = "center"
	}
end

function push( obj, stack )
	stack[ #stack + 1 ] = obj
end

function pop( stack )
	local obj = stack[ #stack ]
	stack[#stack] = nil
	return obj
end

function onProjectileEnded()
	if #projectiles <= 0 then
		endGame( glo.MESSAGE_ON_LOSE )
	else
		loadProjectile()
	end
end

function newFrame()
	if targetHit then
		endGame( glo.MESSAGE_ON_WIN )
	end
end

function init()
	Runtime:addEventListener( "enterFrame", newFrame )
end

init()
