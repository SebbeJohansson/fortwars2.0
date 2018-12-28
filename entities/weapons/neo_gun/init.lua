AddCSLuaFile("shared.lua")
include("shared.lua")

function SWEP:SecondaryAttack()
	if (self.Owner:GetNWInt('energy') >= NEO_JUMP_COST) then
		self.Owner:TakeEnergy(NEO_JUMP_COST)
		self.Owner:SetVelocity(self.Owner:GetForward() * 1000)
	end
end