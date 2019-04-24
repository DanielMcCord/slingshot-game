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

physics = require( "physics" )

local Projectile = {}

function Projectile:new( p )
	p = p or {}
	setmetatable(p, self)
	self.__index = self
	return p
end

-- Places the projectile in the slingshot.
-- The slingshot only needs to be speicified if
-- the projectile has not yet been assigned a slingshot
function Projectile:ready( slingshot )
	-- Remove the listener, because it might already exist
	self:removeEventListener( "touch", self.aim )
	-- Set the projectile's associated slingshot
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