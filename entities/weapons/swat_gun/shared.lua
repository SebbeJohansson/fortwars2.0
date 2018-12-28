if CLIENT then
	SWEP.PrintName = "Swat Gun"
	SWEP.Author	= "Darkspider"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
end

SWEP.HoldType = "ar2"
SWEP.Base				= "darkland_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_rif_m4a1.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_m4a1.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("Weapon_M4A1.Single")
SWEP.Primary.Recoil			= 0.4
SWEP.Primary.Damage			= 11
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.0125
SWEP.Primary.ClipSize		= 30
SWEP.Primary.Delay			= 0.1
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 9999
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "SMG1"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.Delay		= 1

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end

function SWEP:SecondaryAttack()
	//self.Weapon:SetNextSecondaryFire(CurTime() + 2.5)
	
	if SERVER then
	if (self.Owner:HasSpecial(9)) then
	if self.Owner:GetNWInt('energy') >= 100 then
		self.Owner:EmitSound( "weapons/grenade_launcher1.wav" )
		self.Owner:SetNWInt('energy', self.Owner:GetNWInt('energy')-100)
	
		local nade = ents.Create("swatnade")
		nade:SetPos(self.Owner:GetShootPos()+self.Owner:GetAimVector()*10)
		nade.Team = self.Owner:Team()
		nade.LastHolder = self.Owner
		nade:Spawn()
		nade:SetCustomCollisionCheck(true)
		
		print(nade.LastHolder)
		
		local phys = nade:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetMass(10)
			phys:AddVelocity(self.Owner:GetAimVector()*800)
				end
			end
	else
		self.Owner:ChatPrint("You do not own this special ability!")
		end
	end
end