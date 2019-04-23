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

My Ideas:
	Make the level contain collectable targets that do not affect physics,
		but are usable as projectiles. 
--]]

local glo = require( "globals" )
local Projectile = require( "Projectile" )

-- Variables
local projectiles -- stack of all the player's unused projectiles
local projectile -- the active projectile, popped from projectiles
local roundEnded -- text that is generated when the round ends

-- Functions

local endRound
local push
local pop
local onProjectileEnded
local newFrame
local init

-- Displays win or loss message when round ends
function endRound( message )
	if roundEnded == nil then
		roundEnded = display.newText{
			text = message,
			x = glo.WIDTH / 2,
			y = glo.HEIGHT / 2,
			font = native.systemFontBold,
			align = "center"
		}
	end
end

-- Adds the object to the top of a stack
function push( obj, stack )
	stack[ #stack + 1 ] = obj
end

-- Removes and returns the object from the top of a stack
-- Does nothing if the stack is empty
function pop( stack )
	local obj
	if #stack > 0 then
		obj = stack[ #stack ]
		stack[#stack] = nil
	end
	return obj
end

function loadProjectile()
	projectile = pop( projectiles )
	projectile.x = slingshot.x
	projectile.y = slingshot.y
	projectile:addEventListener( "touch", aimProjectile )
end

function onProjectileEnded()
	if #projectiles <= 0 then
		endRound( glo.MESSAGE_ON_LOSE )
	else

		projectile:ready( slingshot )
	end
end

function newFrame()
	if targetHit then
		endRound( glo.MESSAGE_ON_WIN )
	end
end

function init()
	Runtime:addEventListener( "enterFrame", newFrame )
end

init()
