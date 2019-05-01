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

	[DONE](10) Display of slingshot
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
		but are usable as projectiles. They will be pushed to the projectiles stack.
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
local loadProjectile
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

-- Pushes the object to the top of a stack
function push( obj, stack )
	stack[ #stack + 1 ] = obj
end

-- Pops the object from the top of a stack
-- Returns nil if the stack is empty
function pop( stack )
	if #stack > 0 then
		local obj = stack[ #stack ]
		stack[#stack] = nil
		return obj
	else
		return nil
	end
end

-- Loads next projectile from stack into slingshot
function loadProjectile( stack, slingshot )
	projectile = pop( stack )
	projectile:ready( slingshot )
end

-- What to do when the current projectile is done
function onProjectileEnded()
	if #projectiles <= 0 then
		endRound( glo.MESSAGE_ON_LOSE )
	else
		loadProjectile( projectiles, slingshot )
	end
end

-- Run once per frame
function newFrame()
	if targetHit then
		endRound( glo.MESSAGE_ON_WIN )
	end
end

-- Run at app startup
function init()
	physics.start( )
	-- Create platforms/ground
	ground = display.newImageRect( "ground.png", glo.WIDTH, glo.HEIGHT / 10 )
	ground.x = glo.X_CENTER
	ground.y = glo.Y_MAX - ground.height / 2
	physics.addBody( ground, "static" )

	-- Create slingshot
	local sa = require( "slingshot-attributes" )
	slingshot = display.newImageRect( sa.file, sa.width, sa.height )
	slingshot.x = sa.defaultX
	slingshot.y = ground.y - ( slingshot.height + ground.height ) / 2 or sa.defaultY

	-- Create castle

	-- Create target

	-- Create projectiles

	-- Start physics

	-- Load the first projectile
	-- loadProjectile( projectiles, slingshot )

	Runtime:addEventListener( "enterFrame", newFrame )
end

init()
