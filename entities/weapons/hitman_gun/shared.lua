
if CLIENT then
	SWEP.PrintName = "SSR"
	SWEP.Author	= "Darkspider"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
end

SWEP.Base				= "darkland_base"
SWEP.HoldType = "ar2"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_snip_scout.mdl"
SWEP.WorldModel			= "models/weapons/w_snip_scout.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("Weapon_Scout.Single")
SWEP.Primary.Recoil			= 0.41
SWEP.Primary.Damage			= 70
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.0001
SWEP.Primary.ClipSize		= 1
SWEP.Primary.Delay			= .01
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 255
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "SniperRound"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.Delay		= 0.5

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end

SWEP.nextFire = 0
SWEP.lastFire = 0
function SWEP:PrimaryAttack()
	 if self:Clip1() < 1 then self:Reload() return end

	if self.nextFire > CurTime() then return end
		self.nextFire = CurTime() + self.Primary.Delay
		self.lastFire = CurTime()
	// Play shoot sound
	self.Weapon:EmitSound( self.Primary.Sound )
	//self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 		// View model animation
	self.Owner:MuzzleFlash()								// Crappy muzzle light
	self.Owner:SetAnimation( PLAYER_ATTACK1 )				// 3rd Person Animation

	self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone )

	self:TakePrimaryAmmo( 1 )
	
	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
	

		self.Weapon:SetNWInt("prevzoom", self.Weapon:GetNWInt("zoomed"))
		print(self.Weapon:GetNWInt("prevzoom"))

	//if self:Clip1() < 1 then 
	//	timer.Simple(1, function() self:Reload() end)
	//end
	
end

/*---------------------------------------------------------
   Name: SWEP:PrimaryAttack( )
   Desc: +attack1 has been pressed
---------------------------------------------------------*/
function SWEP:CSShootBullet( dmg, recoil, numbul, cone )

	numbul 	= numbul 	or 1
	cone 	= cone 		or 0.01
	if self.Owner:Crouching() then cone = cone * 0.6 end
	if !self.Weapon:GetNWBool("zoomed", false) then cone = cone * 100 end // i think thats innacurate enough
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
	
	if(zoomed) == 1 then
		return .25
	else
		return 1
	end
	self.Weapon:SetNWInt("zoomed", 0)
end

function SWEP:Think()
		if self.Weapon:GetNWInt("zoomed") != 0 then
			LocalPlayer():GetViewModel():SetRenderMode( RENDERMODE_TRANSALPHA )
			LocalPlayer():GetViewModel():SetColor(Color(255, 255, 255, 0))
		else
			LocalPlayer():GetViewModel():SetRenderMode( RENDERMODE_NORMAL )
			LocalPlayer():GetViewModel():SetColor(Color(255, 255, 255, 255))
		end
end

end
