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
	[DONE](10) Display of castle on platform with target object inside
	[DONE](10) Display tracking of projectile as user drags
	[DONE](10) Physics of projectile in flight
	[DONE](10) Physics of projectile knocking over castle parts
	[DONE](10) At least two castle parts are connected by a joint
	[DONE](10) Display of projectile causing damage to castle parts over repeated hits
	[DONE](10) Castle parts explode/disappear after enough hits (individually)
	[DONE](10) User wins if the target object is hit,
		but loses if runs out of projectiles
	[DONE](10) Good comments, indentation, and function structure

Extra Credit:

	(0-5) Interesting/creative coolness in any area,
		above and beyond the minimum requirements above.

Notes:
	I made the blocks take damage according to the amount of force with which they are
		struck. The amount of damage is shown using with a red tint on the block.

	I chose not to use "static" for the projectile because I don't want it to
		interact with the physics world at all until fired.

	Coloring of projectiles is cosmetic, and lets you see that the top one is loaded.
--]]

local glo = require( "globals" )
local physics = require( "physics" )
local widget = require( "widget" )
local Projectile = require( "Projectile" )

-- Constants
local projectileCount = 6 -- how many projectiles the player starts with
local damageMultiplier = 1000 -- hp lost by blocks per newton from projectile

-- Variables
local slingshot -- the display object for the slingshot, which is not a physics body
local projectiles -- stack of all the player's unused projectiles
local castle -- table of all the physics objects that make up the castle
local targets -- Display group of targets. Only one child for now.
local projectile -- the active projectile, popped from projectiles
local roundEnded -- text that is generated when the round ends

-- Functions
local endRound
local push
local pop
local arrayAppend
local onProjectilePostCollision
local loadProjectile
local onProjectileEnded
local targetHit
local projectileInPlay
local kill
local verticalHeight
local resetProjectiles
local newFrame
local init

-- Displays win or loss message when round ends
function endRound( message )
	if not roundEnded then
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

-- Handles projectile colliding with a block or target
function onProjectilePostCollision ( event )
	local o = event.other
	if o.hp then -- it's a block with hitpoints
		o.impacted( event )
	elseif o.isTarget then
		targetHit( o )
	end
end

-- Loads next projectile from stack into slingshot
function loadProjectile( stack )
	projectile = pop( stack )
	projectile:ready( slingshot )
	projectile:addEventListener( "postCollision", onProjectilePostCollision )
end

-- What to do when the current projectile is done
function onProjectileEnded()
	if #projectiles <= 0 then
		endRound( glo.MESSAGE_ON_LOSE )
	else
		loadProjectile( projectiles, slingshot )
	end
end

-- What to do when target is hit. Checks if game has been won.
function targetHit( obj )
	kill( obj )
	if targets.numChildren <= 0 then
		endRound( glo.MESSAGE_ON_WIN )
	end
end

-- Returns a boolean giving whether the projectile is still available to physics
function projectileInPlay()
	-- return true unless either:
	return (
		-- 1) projectile is nil,
		projectile
		-- 2) projectile is both active and asleep,
		and ( not projectile.isBodyActive or projectile.isAwake )
		-- 3) projectile is completely off the left or right ends of the display, or
		and (
			math.abs( ( projectile.x or 0 ) - glo.X_CENTER )
			<= glo.WIDTH / 2 + 2 * ( projectile.path and projectile.path.radius or 0 ) )
		-- 4) projectile is completely off the bottom end of the display.
		and ( ( projectile.y or 0 ) - glo.Y_MAX <= 2 * ( projectile.path and projectile.path.radius or 0 ) )
	)
end

-- Completely removes and deletes the given object
function kill( obj )
	obj:removeSelf()
	obj = nil
end

-- Accurately calculates the vertical height of a rectangle that is rotated at any angle.
function verticalHeight( obj )
	return obj.width * math.sin( math.rad( obj.rotation ) ) / 2
		+ obj.height * math.cos( math.rad( obj.rotation ) ) / 2
end

-- Removes the current projectile from play if applicable,
-- replenishes any missing rounds, and then loads one into the slingshot.
function resetProjectiles()
	if projectile then
		kill(projectile)
	end
	local projRadius = slingshot.width / 4
	for i = 1, projectileCount do
		projectiles[i] = projectiles[i] or Projectile:new(
			slingshot.x - slingshot.width,
			slingshot.y + slingshot.height / 2 - projRadius * ( 2 * i - 1 ),
			projRadius
		)
	end

	-- Load the first projectile
	loadProjectile( projectiles, slingshot )
end

-- Run once per frame
function newFrame()
	if not projectileInPlay() then
		if projectile then
			kill(projectile)
		end
		onProjectileEnded()
	end
end

-- Run at app startup
function init()
	physics.start( )

	-- Create ground
	local ground = display.newImageRect( "ground.png", glo.WIDTH, glo.HEIGHT / 10 )
	ground.x = glo.X_CENTER
	ground.y = glo.Y_MAX - ground.height / 2
	physics.addBody( ground, "static" )

	-- Create platform
	local platform = display.newImageRect( "ground.png", glo.WIDTH / 5, glo.HEIGHT / 20 )
	platform.x = glo.X_MIN + glo.WIDTH * 0.75
	platform.y = glo.Y_MIN + glo.HEIGHT * 0.6
	physics.addBody( platform, "static" )

	-- Create wall that blocks the top three-fourths of the right side
	local wall = display.newImageRect( "wall.png", glo.WIDTH / 50, 3 * glo.HEIGHT / 4 )
	wall.x = glo.X_MAX - wall.width / 2
	wall.y = glo.Y_MIN + glo.HEIGHT * 0.25
	physics.addBody( wall, "static" )

	-- Create slingshot
	local sa = require( "slingshot-attributes" )
	slingshot = display.newImageRect( sa.file, sa.width, sa.height )
	slingshot.x = sa.defaultX
	slingshot.nockHeight = sa.nockHeight
	slingshot.releaseDuration = sa.releaseDuration
	slingshot.y = ground.y - ( slingshot.height + ground.height ) / 2 or sa.defaultY

	-- Create castle with various default values
	castle = {
		default = {
			rotation = 0,
			width = 40,
			height = 10,
			x = 0.75 * glo.WIDTH + glo.X_MIN,
			-- Note: default.y is platform level, which you probably don't want.
			-- castle:newBlock (below) does trig magic to fix this.
			y = platform.y - (platform.height) / 2,
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
		obj.y = self.default.y - verticalHeight( obj )
		obj.maxHP = 100
		obj.hp = 100

		-- Get the remaining percentage of HP, as a value ranging from 0 and 1
		function obj.percentHP()
			return obj.hp / obj.maxHP
		end

		-- what to do when obj is hit
		function obj.impacted( event )
			obj.hp = obj.hp - event.force * damageMultiplier
			obj:setFillColor( 1, obj.percentHP(), 1 )
			-- Check if obj hitpoints have reached zero
			if obj.hp <= 0 then
				-- delete the object and make an explosion animation
				local e = display.newCircle( obj.x, obj.y, (obj.width + obj.height)/4 )
				obj:removeSelf()
				obj = nil
				transition.to(e, {
					xScale = 2,
					yScale = 2,
					alpha = .5,
					onComplete = kill
				})
			end
		end
		arrayAppend( obj, castle )
		return obj
	end

	-- Individual parts of the castle
	local roofRight = castle:newBlock( 45 )
	roofRight.x = castle.default.x
	roofRight.y = roofRight.y
		- (roofRight.width + roofRight.height)

	local roofLeft = castle:newBlock( roofRight.rotation - 90,
		roofRight.width, roofRight.height )
	roofLeft.x = roofRight.x + (roofRight.height - roofRight.width) / math.sqrt(2)
	roofLeft.y = roofRight.y

	local wallRight = castle:newBlock( 90, roofRight.width, roofRight.height )
	wallRight.x = castle.default.x
		+ ( roofRight.width / math.pow(2, 1.5) - roofRight.height / 2 )

	local wallLeft = castle:newBlock( 90, wallRight.width, wallRight.height )
	wallLeft.x = castle.default.x
		+ (roofRight.height - roofRight.width) / math.sqrt(2)
		- ( roofRight.width / math.pow(2, 1.5) - roofRight.height / 2 )
	
	local ceiling = castle:newBlock(
		0,
		( wallRight.x - wallLeft.x ) + ( wallRight.height + wallLeft.height ) / 2,
		wallRight.height
	)
	ceiling.x = ( roofLeft.x + roofRight.x ) / 2
	ceiling.y = castle.default.y
		- castle.blockVertH( ceiling )
		- wallRight.width

	for i=1, #castle do
		physics.addBody( castle[i] )
	end

	-- join the two roof blocks
	physics.newJoint( "weld", roofRight, roofLeft, ceiling.x,
		castle.blockVertH(roofRight) / 2 - roofRight.height * math.sqrt(2) )

	-- Create target
	targets = display.newGroup()
	targets.default = {
		filename = "target.png",
		scale = 1 / 16,
	}
	targets.default.width = 394 * targets.default.scale
	targets.default.height = 492 * targets.default.scale

	-- Helper to add new targets to the targets group
	-- Takes x,y coordinates and the required args for display.newImageRect
	function targets:newTarget( x, y, filename, width, height )
		local f = filename or self.default.filename
		local w = width or self.default.width
		local h = height or self.default.height
		local obj = display.newImageRect( f, w, h )
		obj.x = x
		obj.y = y
		obj.isTarget = true
		targets:insert( obj )
		
		return obj
	end

	-- Create instance of the target
	local onlyTarget = targets:newTarget( ceiling.x,
		castle.default.y - targets.default.height / 2 )
	physics.addBody( onlyTarget )

	-- Create reset button
	widget.newButton{
		top = glo.Y_MIN,
		left = glo.X_MIN,
		width = glo.WIDTH * 0.15,
		label = "Reset Projectiles",
		onRelease = resetProjectiles,
	}

	-- Create projectiles
	projectiles = {}
	resetProjectiles()

	Runtime:addEventListener( "enterFrame", newFrame )
end

init()
