ENT.Spawnable			= false
ENT.AdminSpawnable		= false

include( "shared.lua" )


function ENT:Initialize()
	self.Entity:DrawShadow(false)
end
