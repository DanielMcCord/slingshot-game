-----------------------------------------------------------------------------------------
--
-- Projectile.lua
--
-- Author:		Daniel McCord
-- Instructor:	Dave Parker
-- Course:		CSCI 79
-- Semester:	Spring 2019
-- Assignment:	Slingshot Game
--
-----------------------------------------------------------------------------------------

local physics = require( "physics" )

local Projectile = {}

function Projectile:new( xCenter, yCenter, radius, parent )
	local p
	if parent then
		p = display.newCircle( parent, xCenter, yCenter, radius )
	else
		p = display.newCircle( xCenter, yCenter, radius )
	end
	-- Metatables were not working correctly with ShapeObject class,
	-- so I forced the issue by adding these methods the old way.
	p.ready = self.ready
	p.aim = self.aim
	p.fire = self.fire
	return p
end

-- Places the projectile in the slingshot.
function Projectile:ready( slingshot )
	-- Remove the listener, because it might already exist
	self:removeEventListener( "touch", self.aim )
	-- Set the projectile's associated slingshot, or fall back on the existing one.
	self.slingshot = slingshot or self.slingshot
	-- nock the projectile in its slingshot
	self.x = self.slingshot.x
	self.y = self.slingshot.y
	-- listen for player trying to use the loaded projectile
	self:addEventListener( "touch", self.aim )
end

function Projectile:aim( event )
	if event.phase == "began" or "moved" then
		local sling = self.slingshot
		self.x = event.x
		self.y = event.y
		self.xPower = ( sling.x - self.x ) / sling.releaseDuration
		self.yPower = ( sling.y - self.y ) / sling.releaseDuration
	elseif event.phase == "ended" then
		self:fire()
	else -- event.phase == "cancelled" -- only other documented phase for this event
		self:ready()
	end
end

function Projectile:fire()
	-- Prevent user from messing with projectile after firing
	self:removeEventListener( "touch", self.aim )
	transition.to( self, {
		time = self.slingshot.releaseDuration,
		x = self.slingshot.x,
		y = self.slingshot.y,
	} )
end

return Projectile