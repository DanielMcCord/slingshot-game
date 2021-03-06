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

-- Constructor. takes arguments for display.newCircle.
-- As with newCircle, parent is an optional parameter.
function Projectile:new( xCenter, yCenter, radius, parent )
	local p
	if parent then
		p = display.newCircle( parent, xCenter, yCenter, radius )
	else
		p = display.newCircle( xCenter, yCenter, radius )
	end
	-- Give each projectile a random color
	p:setFillColor(
		math.random() / 3 + 0.5,
		math.random() / 3 + 0.5,
		math.random() / 3 + 0.5
	)
	-- Metatables were not working correctly with ShapeObject class,
	-- so I forced the issue by adding these methods the old way.
	p.ready = self.ready
	p.aim = self.aim
	p.fire = self.fire
	p.fired = self.fired
	p.onCollison = self.onCollison
	return p
end

-- Places the projectile in the slingshot.
function Projectile:ready( slingshot )
	-- Set the projectile's associated slingshot, or fall back on the existing one.
	self.slingshot = slingshot or self.slingshot
	-- nock the projectile in its slingshot
	self.x = self.slingshot.x
	self.y = self.slingshot.y - slingshot.height * ( slingshot.nockHeight - 0.5 )
	-- listen for player trying to use the loaded projectile
	self:addEventListener( "touch", self.aim )
end

-- Drags the projectile away from slingshot before firing
function Projectile.aim( event )
	local proj = event.target -- quick workaround
	if event.phase == "began" then
		display.getCurrentStage():setFocus( proj )
	elseif event.phase == "moved" then
		proj.x = event.x
		proj.y = event.y
	elseif event.phase == "ended" then
		display.getCurrentStage():setFocus( nil )
		proj:removeEventListener( "touch", proj.aim )
		proj:fire()
	else -- event.phase == "cancelled" -- only other documented phase for this event
		proj:ready()
	end
end

-- Snaps the projectile back towards the slingshot, giving it momentum
function Projectile:fire()
	local slingX = self.slingshot.x
	local slingY = self.slingshot.y - self.slingshot.height * ( self.slingshot.nockHeight - 0.5 )
	-- velocity = deltaPosition / deltaTime,
	-- so the below values should be exact.
	-- Note that velocity is m/s, but transition time is in ms,
	-- hence the factor of 1000.
	self.startingXVelocity = 1000 * ( slingX - self.x ) / self.slingshot.releaseDuration
	self.startingYVelocity = 1000 * ( slingY - self.y ) / self.slingshot.releaseDuration
	transition.to( self, {
		time = self.slingshot.releaseDuration,
		x = slingX,
		y = slingY,
		onComplete = Projectile.fired
	} )
end

-- Called when the projectile leaves the slingshot to start flying
function Projectile.fired( obj )
	-- The projectile is finally brought into the physics world,
	-- with the appropriate velocity values already calculated as soon as the
	-- slingshot is released.
	physics.addBody(obj)
	obj:setLinearVelocity( obj.startingXVelocity, obj.startingYVelocity )

end

return Projectile