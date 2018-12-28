if CLIENT then
	SWEP.PrintName = "Razifle"
	SWEP.Author	= "Darkspider"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
end

SWEP.Base				= "darkland_base"
SWEP.HoldType = "ar2"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_snip_sg550.mdl"
SWEP.WorldModel			= "models/weapons/w_snip_sg550.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("Weapon_sg550.Single")
SWEP.Primary.Recoil			= 1.5
SWEP.Primary.Damage			= 40
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.0001
SWEP.Primary.ClipSize		= 3
SWEP.Primary.Delay			= 0.01
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 2550
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "pistol"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.Delay		= 0.5

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
SWEP.nextFire = 0
SWEP.lastFire = 0

function SWEP:PrimaryAttack()

	//if self.Weapon:GetNWBool( "reloading" ) == true then return end
	
	if self.nextFire > CurTime() then return end
		self.nextFire = CurTime() + self.Primary.Delay
		self.lastFire = CurTime()
	// Play shoot sound
	self.Weapon:EmitSound( self.Primary.Sound )
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 		// View model animation
	self.Owner:MuzzleFlash()								// Crappy muzzle light
	self.Owner:SetAnimation( PLAYER_ATTACK1 )				// 3rd Person Animation
	// Shoot the bullet
	self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone )
	
	// Remove 1 bullet from our clip
	self:TakePrimaryAmmo( 1 )
	
	// Punch the player's view
	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
	

	
	if self.Weapon:Clip1() < 1 then
		self:Reload()
	end
	
end

/*---------------------------------------------------------
   Name: SWEP:PrimaryAttack( )
   Desc: +attack1 has been pressed
---------------------------------------------------------*/
function SWEP:CSShootBullet( dmg, recoil, numbul, cone )

	numbul 	= numbul 	or 1
	cone 	= cone 		or 0.01
	if self.Owner:Crouching() then cone = cone * 0.6 end
	//if !self.Weapon:GetNWBool("zoomed", false) then cone = cone * 100 end // i think thats innacurate enough
	local bullet = {}
	bullet.Num 		= numbul
	bullet.Src 		= self.Owner:GetShootPos()			// Source
	bullet.Dir 		= self.Owner:GetAimVector()			// Dir of bullet
	bullet.Spread 	= Vector( cone, cone, 0 )			// Aim Cone
	bullet.Tracer	= 4								// Show a tracer on every x bullets 
	bullet.Force	= 5									// Amount of force to give to phys objects
	bullet.Damage	= dmg
	self.Owner:FireBullets( bullet )

	// CUSTOM RECOIL !
	if CLIENT then
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil
		self.Owner:SetEyeAngles( eyeang )

	end
end

if CLIENT then
function SWEP:AdjustMouseSensitivity()
	local zoomed = self.Weapon:GetNWInt("zoomed")
	
	if (zoomed) == 1 then
		return .25
	elseif (zoomed) == 2 then
		return .125
	else
		return 1
	end
	self.Weapon:SetNWInt("zoomed", 0)
end
end

function SWEP:Think()
	if CLIENT then
		if self.Weapon:GetNWInt("zoomed") != 0 then
			LocalPlayer():GetViewModel():SetRenderMode( RENDERMODE_TRANSALPHA )
			LocalPlayer():GetViewModel():SetColor(Color(255, 255, 255, 0))
		else
			LocalPlayer():GetViewModel():SetRenderMode( RENDERMODE_NORMAL )
			LocalPlayer():GetViewModel():SetColor(Color(255, 255, 255, 255))
		end
	end
end
