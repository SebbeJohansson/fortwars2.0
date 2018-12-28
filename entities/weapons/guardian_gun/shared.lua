if SERVER then
  AddCSLuaFile( "shared.lua" )
end

if CLIENT then
  SWEP.PrintName     = "Boomstick"
  SWEP.Author	= "Onslaught"
  SWEP.Slot          = 2
  SWEP.SlotPos       = 1
  SWEP.DrawCrosshair = false
end

SWEP.Base               = "darkland_base"
SWEP.HoldType = "shotgun"
SWEP.ViewModel          = "models/weapons/v_shot_xm1014.mdl"
SWEP.WorldModel         = "models/weapons/w_shot_xm1014.mdl"
SWEP.Primary.Sound      = Sound( "Weapon_XM1014.Single" )
SWEP.Primary.Recoil			= 2
SWEP.Primary.Damage			= 4
SWEP.Primary.NumShots		= 16
SWEP.Primary.Cone			= 0.225
SWEP.Primary.ClipSize		= 2
SWEP.Primary.Delay			= .025
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 9999
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "BuckShot"
SWEP.Secondary.Recoil			= 4
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.Delay		= 5
SWEP.Secondary.Sound		= Sound("weapons/shotgun/shotgun_dbl_fire.wav")
if CLIENT then NextShotty = 0 end

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end

--RIPPED OUT OF THE CSS GUN, I DID NOT MAKE THIS
function SWEP:Reload()
	if ( self.Weapon:GetNetworkedBool( "reloading", false ) ) then return end
	if ( self.Weapon:Clip1() < self.Primary.ClipSize && self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then
		
		self.Weapon:SetNetworkedBool( "reloading", true )
		self.Weapon:SetVar( "reloadtimer", CurTime() + 0.3 )
		self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
	end

	self.Weapon:SetNextPrimaryFire( CurTime() + 3 )

end

function SWEP:PrimaryAttack()

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + 3 )
	
	self.Owner.NextShotty = self.Owner.NextShotty or 0
	if SERVER and self.Owner.NextShotty > CurTime() then return end
	if CLIENT and NextShotty > CurTime() then return end
	
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
	NextShotty = CurTime() + 0.95
	self.Owner.NextShotty = CurTime() + 0.95
	self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
	
	if self.Weapon:Clip1() < 1 then
		self:Reload()
	end
end

function SWEP:SecondaryAttack()

	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	
	if SERVER then
		net.Start("cooldown")
		net.WriteInt(self.Weapon:GetNextSecondaryFire(), 32)
		net.Send(self.Owner)
	end

	--draw the cooldown bar
	if CLIENT then
	
		net.Receive("cooldown", function(len)
			local nextfire = net.ReadInt(32)
			local cooloff = vgui.Create( "DPanel" )
			function cooloff:Paint( w, h )
				draw.RoundedBox( 8, 0, 0, w, h, Color( 0, 150, 0 ) )
			end
			
			function cooloff:Think()							
				cooloff:SetSize( 50*(math.ceil(CurTime()-nextfire-1)*-1), 20  )	
			end		
			cooloff:SetPos(ScrW() - 290, ScrH() - 100)
	
		end)
	end
	
	self.Owner.NextShotty = self.Owner.NextShotty or 0
	if SERVER and self.Owner.NextShotty > CurTime() then return end
	if CLIENT and NextShotty > CurTime() then return end
	
	// Play shoot sound
	if self.Weapon:Clip1() > 1 then
		self.Weapon:EmitSound( self.Secondary.Sound )
	else
		self.Weapon:EmitSound( self.Primary.Sound )
	end
	
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 		// View model animation
	self.Owner:MuzzleFlash()								// Crappy muzzle light
	self.Owner:SetAnimation( PLAYER_ATTACK1 )				// 3rd Person Animation
	
	// Shoot the bullet
	self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil, (self.Primary.NumShots*tonumber(self.Weapon:Clip1())), self.Primary.Cone )
	
	// Remove all bullets from our clip
	self:TakePrimaryAmmo( self.Weapon:Clip1() )
	
	// Punch the player's view
	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Secondary.Recoil, math.Rand(-0.1,0.1) *self.Secondary.Recoil, 0 ) )
	NextShotty = CurTime() + 0.95
	self.Owner.NextShotty = CurTime() + 0.95
	self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
	
	if self.Weapon:Clip1() < 1 then
		self:Reload()
	end
end

function SWEP:Think()
	if ( self.Weapon:GetNetworkedBool( "reloading", false ) ) then	
		if ( self.Weapon:GetVar( "reloadtimer", 0 ) < CurTime() ) then
			// Finsished reload -
			if ( self.Weapon:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 ) then
				self.Weapon:SetNetworkedBool( "reloading", false )
				return
			end	
			// Next cycle
			self.Weapon:SetVar( "reloadtimer", CurTime() + 0.3 )
			self.Weapon:SetVar( "reloadtimer", CurTime() + 0.3 )
			self.Owner:GetViewModel():SetPlaybackRate( .2 )
			self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
			
			// Add ammo
			self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false )
			self.Weapon:SetClip1(  self.Weapon:Clip1() + 1 )
			
			// Finish filling, final pump
			if ( self.Weapon:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 ) then
				self.Weapon:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
			else		
			end		
		end
	end
end