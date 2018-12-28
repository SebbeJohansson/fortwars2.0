if SERVER then
	AddCSLuaFile("shared.lua")
end

SWEP.HoldType = "ar2"
function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end


if CLIENT then
	SWEP.PrintName = "Terrorist Gun"
	SWEP.Author	= "Darkspider"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
end

SWEP.Base				= "darkland_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_rif_ak47.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_ak47.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("Weapon_AK47.Single")
SWEP.Primary.Recoil			= .5
SWEP.Primary.Damage			= 12
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.015
SWEP.Primary.ClipSize		= 35
SWEP.Primary.Delay			= 0.1
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 9999
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "smg1"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:PrimaryAttack()
	if self.nextFire > CurTime() then return end
	self.nextFire = CurTime() + self.Primary.Delay
	self.lastFire = CurTime()
	
	self.Weapon:EmitSound(Sound("Weapon_AK47.Single"))
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone )
	
	self:TakePrimaryAmmo( 1 )
	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
	
	if SERVER then

		if self.Weapon:Clip1() < 1 then
		
			if self.Owner:HasSpecial(10) then
			self.Owner:TakeEnergy(20)
			
			if self.Owner:Energy() <= 0 then
				self:Reload()
			end
			else
			self:Reload()
			end
			
		end
	end
end
