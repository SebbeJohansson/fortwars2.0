AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )


function ENT:Initialize()
	
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType(  MOVETYPE_VPHYSICS )   
    self:SetSolid( SOLID_VPHYSICS )
	self:SetHealth(self.TBL.HEALTH)
	self:SetNWInt("MaxHP",self.TBL.HEALTH)
	//self:SetNWInt("team", tonumber(self:GetOwner():Team()) )
	self:DrawShadow(false)
	
	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end
end



function ENT:SetPropTable(t)
	self.TBL = t
end

function ENT:UpdateTransmitState() 
	return TRANSMIT_PVS
end

function ENT:OnTakeDamage( dmginfo )
	local entteam = self.Team
	local amt = dmginfo:GetDamage()
	
	if !DM_MODE then return end
		self:SetHealth(self:Health() - dmginfo:GetDamage())	
	if self:Health() < 1 then 
		self:Remove()
		LowerBoxCount(self.Team)
	end
	
	if entteam != dmginfo:GetAttacker():Team() then
		dmginfo:GetAttacker().BuildingDamage = dmginfo:GetAttacker().BuildingDamage + amt
	end
	
end

function ENT:Think()

	local maxhp = self.TBL.HEALTH
	local entteam = self.Team
	local calc = tonumber((self:Health() / maxhp) * 255)

	if entteam == 1 then
		self:SetColor( Color(0, 0, calc ))
		
	elseif entteam == 2 then
		self:SetColor( Color(calc, 0, 0 ))
		
	elseif entteam == 3 then
		self:SetColor( Color( calc, calc, 0 ))
		
	elseif entteam == 4 then
		self:SetColor( Color(0, calc, 0 ))
	end

end

