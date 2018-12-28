
if CLIENT then
	SWEP.PrintName = "Grenades"
	SWEP.Author	= "Darkspider"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
	SWEP.ViewModelFOV   	= 70
end

SWEP.Base				= "darkland_base"
SWEP.HoldType = "melee"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true
SWEP.ViewModelFlip 		= false
SWEP.Primary.Sound = nil
SWEP.ViewModel			= "models/weapons/v_grenade.mdl"
SWEP.WorldModel			= "models/weapons/w_grenade.mdl"

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end

local clientFix = 0 --dumbass function calls like 6 times for some reason, this hacky fucker should fix it
function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + 2.5)
	self.Weapon:SetNextSecondaryFire(CurTime() + 2.5)
	if CLIENT && clientFix > RealTime() then return end
	
	if SERVER then
	
		local nade = ents.Create("nade")
		nade:SetPos(self.Owner:GetShootPos()+self.Owner:GetAimVector()*11)
		nade.Team = self.Owner:Team()
		nade.LastHolder = self.Owner
		nade:Spawn()
		
		local phys = nade:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetMass(1)
			phys:AddVelocity(self.Owner:GetAimVector()*1200)
		end
	else
		clientFix = RealTime()+0.5
	end
	 self.Weapon:SendWeaponAnim(ACT_VM_PULLBACK_HIGH)
	 timer.Simple(0.1,function()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	end)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )				// 3rd Person Animation
end

function SWEP:SecondaryAttack()
	

	if CLIENT && clientFix > RealTime() then return end
	
	if SERVER then
	
		if self.Owner:HasSpecial(16) and self.Owner:Energy() >= 100 then
		self.Weapon:SetNextPrimaryFire(CurTime() + 2.5)
		self.Owner:TakeEnergy(100)
		
		local nade = ents.Create("instanade")
		nade:SetPos(self.Owner:GetShootPos()+self.Owner:GetAimVector()*20)
		nade.Team = self.Owner:Team()
		nade.LastHolder = self.Owner
		nade:Spawn()
		
		local phys = nade:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetMass(1)
			phys:AddVelocity(self.Owner:GetAimVector()*5000)
		end
		
		self.Weapon:SendWeaponAnim(ACT_VM_PULLBACK_HIGH)
		timer.Simple(0.1,function()
			self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		end)
		
	elseif !self.Owner:HasSpecial(16) then
		self.Owner:ChatPrint("You do not have the special ability for this class. Press F1 and look in the Classes tab to buy it.") 
	return
		
	else
		clientFix = RealTime()+0.5
	end

	self.Owner:SetAnimation( PLAYER_ATTACK1 )				// 3rd Person Animation

end
end