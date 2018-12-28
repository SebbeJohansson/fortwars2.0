SWEP.HoldType = "pistol"
AddCSLuaFile("shared.lua")
include("shared.lua")
	
function SWEP:PrimaryAttack()
	self.Owner:EmitSound(Sound("darkland/fortwars/bomberlol.mp3"),100,100)
	self.Weapon:SetNextPrimaryFire(CurTime() + 4)
	timer.Simple(2, function() self:Boom() end)
end

function SWEP:Boom()

	if !self or !self.Owner or !self.Owner:Alive() then return end
	
	local height, entpos, dis;
	local pos = self.Owner:GetPos()
	local others = ents.FindInSphere( self.Owner:GetPos(), 250  )
		for _, ent in pairs( others ) do
			height = 0
		if IsValid(ent) then
			height = 50
			width = 20
			
			if ent:IsPlayer() then
				entpos = ent:GetPos()+Vector(0,0,height)
			else
				entpos = ent:GetPos()
			end
			
			dis = entpos:Distance(pos)
			
			local trace = { start = pos, endpos = entpos, filter = self.Owner }
			local tr = util.TraceLine( trace )
			
				if tr.Entity == ent and tr.Entity:IsPlayer() then
				
							
						if dis <= (250+height) and dis >= (50+height) then
							ent:TakeDamage( (330+width)-dis, self.Owner )
						elseif dis < (50+height) then
							ent:TakeDamage(300, self.Owner)
						end
						
				elseif tr.Entity == ent then
					ent:TakeDamage( ((300-dis)/250)*325  , self.Owner )
				
			end
		end
	end
	
	local Effect = EffectData()
	Effect:SetOrigin(pos)
	Effect:SetStart(pos)
	Effect:SetMagnitude(512)
	Effect:SetScale(128)
	util.Effect("Explosion", Effect)
	timer.Simple(0.1, function() self.Owner:Kill() end)
	
end

local prevVel = Vector(0,0,0)
local pressed = false

function SWEP:SecondaryAttack()
 
  if !self.Owner:OnGround() then return end
  
   if self.Owner:HasSpecial(8) and self.Owner:Energy() >= 100 then
  
	if SERVER then
      self.Owner:TakeEnergy(100)
      local bomb = ents.Create("sent_bomb")
      bomb:SetPos(self.Owner:GetPos()+ Vector (0,0,2))
      bomb:SetAngles(Angle(0,self.Owner:GetAngles().y,0))
      bomb:SetOwner(self.Owner)
      bomb.Team = self.Owner:Team()
      bomb:Spawn()
  end
  elseif !self.Owner:HasSpecial(8) then
	self.Owner:ChatPrint("You do not have the special ability for this class. Press F1 and look in the Classes tab to buy it.") 
	return
end
  
end
