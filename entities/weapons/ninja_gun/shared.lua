
if CLIENT then
	SWEP.PrintName = "Ninja Gun"
	SWEP.Author	= "Darkspider"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
end

SWEP.Base				= "darkland_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_pist_usp.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_usp.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= true

SWEP.Primary.Sound			= Sound("Weapon_USP.Single")
SWEP.Primary.Recoil			= 1
SWEP.Primary.Damage			= 14
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.015
SWEP.Primary.ClipSize		= 12
SWEP.Primary.Delay			= 0.2
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 9999
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "pistol"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.nextFire = 0
SWEP.lastFire = 0

function SWEP:PrimaryAttack()
	if self.nextFire > CurTime() then return end
	self.nextFire = CurTime() + self.Primary.Delay
	self.lastFire = CurTime()
	
	self.Weapon:EmitSound(Sound("Weapon_USP.Single"))
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone )
	
	self:TakePrimaryAmmo( 1 )
	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
	
	if self.Weapon:Clip1() < 1 then
		self:Reload()
	end
end


function SWEP:SecondaryAttack()
if SERVER then
	if (self.Owner:HasSpecial(3)) then
	
	if self.Owner:GetNWInt("energy") >= 100 then
		self.Owner:SetNWBool("superjump", true)
		self.Owner:EmitSound(Sound("HL1/fvox/activated.wav"))
		self.Owner:SetNWInt("energy", self.Owner:GetNWInt("energy")-100)
	end
	
		if self.Owner:GetNWBool("superjump") == true then
		
			if !self.Owner:OnGround() then 
				self.Owner:SetVelocity( Vector(0, 0, 500) )
				self.Owner:SetNWBool("superjump", false)
			end
		end
	else
	self.Owner:ChatPrint("You do not own this special ability!")
		end
	end
end

function SWEP:Reload()
	self.Weapon:DefaultReload( ACT_VM_RELOAD );
end