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
	[DONE](10) At least two castle parts are connected by a joint
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
local physics = require( "physics" )
local Projectile = require( "Projectile" )

-- Variables
local ground -- static platform at bottom of screen
local slingshot
local projectiles -- stack of all the player's unused projectiles
local castle -- table of all the physics objects that make up the castle
local projectile -- the active projectile, popped from projectiles
local roundEnded -- text that is generated when the round ends

-- Functions
local endRound
local push
local pop
local arrayAppend
local loadProjectile
local onProjectileEnded
local onTargetHit
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

-- Appends item to end of an array. Really just alias of push().
function arrayAppend( obj, arr )
	push( obj, arr )
end

-- Loads next projectile from stack into slingshot
function loadProjectile( stack )
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

function onTargetHit()
	endRound( glo.MESSAGE_ON_WIN )
end

-- Run once per frame
function newFrame()

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

	-- Create castle with various default values
	castle = {
		default = {
			rotation = 0,
			width = 60,
			height = 10,
			x = 0.75 * glo.WIDTH + glo.X_MIN,
			-- Note: default.y is ground level, which you probably don't want.
			-- castle:newBlock (below) does trig magic to fix this.
			y = ground.y - (ground.height) / 2,
			filename = "block.png"
		}
	}

	-- Accurately calculates the vertical height of the rectangular block.
	function castle.blockVertH( block )
		return block.width * math.sin( math.rad( block.rotation ) ) / 2
			+ block.height * math.cos( math.rad( block.rotation ) ) / 2
	end

	-- Helper function for adding blocks to castle.
	-- Resulting y coordinate is such that block is resting exactly on the ground.
	function castle:newBlock( rotation, width, height, filename )
		local f = filename or self.default.filename
		local w = width or self.default.width
		local h = height or self.default.height
		local obj = display.newImageRect( f, w, h )
		obj.rotation = rotation or self.default.rotation
		obj.x = self.default.x
		obj.y = self.default.y - castle.blockVertH( obj )
		obj.hp = 100
		arrayAppend( obj, castle )
		return obj
	end

	local roofRight = castle:newBlock( 45 )
	roofRight.x = castle.default.x
	roofRight.y = roofRight.y
		- (castle.default.width + castle.default.height)

	local roofLeft = castle:newBlock( roofRight.rotation - 90 )
	roofLeft.x = roofRight.x + (roofRight.height - roofRight.width) / math.sqrt(2)
	roofLeft.y = roofRight.y

	local wallRight = castle:newBlock( 90 )
	wallRight.x = castle.default.x
		+ ( castle.default.width / math.pow(2, 1.5) - castle.default.height / 2 )

	local wallLeft = castle:newBlock( 90 )
	wallLeft.x = castle.default.x
		+ (roofRight.height - roofRight.width) / math.sqrt(2)
		- ( castle.default.width / math.pow(2, 1.5) - castle.default.height / 2 )
	
	local ceiling = castle:newBlock(
		0,
		( wallRight.x - wallLeft.x ) + ( wallRight.height + wallLeft.height ) / 2
	)
	ceiling.x = ( roofLeft.x + roofRight.x ) / 2
	ceiling.y = castle.default.y
		- castle.blockVertH( ceiling )
		- castle.default.width

	for i=1, #castle do
		physics.addBody( castle[i] )
	end

	physics.newJoint( "weld", roofRight, roofLeft,
		( roofLeft.x + roofRight.x ) / 2,
		castle.blockVertH(roofRight) / 2 - roofRight.height * math.sqrt(2) )

	-- Create target

	-- Create projectiles

	-- Load the first projectile
	-- loadProjectile( projectiles, slingshot )

	Runtime:addEventListener( "enterFrame", newFrame )
end

init()
