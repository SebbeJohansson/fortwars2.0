
if ( CLIENT ) then

	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= true
	SWEP.ViewModelFOV		= 82
	SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes	= true
	
	// This is the font that's used to draw the death icons
	//surface.CreateFont( "csd", ScreenScale( 30 ), 500, true, true, "CSKillIcons" )
	//surface.CreateFont( "csd", ScreenScale( 60 ), 500, true, true, "CSSelectIcons" )

end

SWEP.Author			= "Darkspider(really i just copied it from the css one though)"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound			= Sound( "Weapon_AK47.Single" )
SWEP.Primary.Recoil			= 1.5
SWEP.Primary.Damage			= 40
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.Delay			= 0.15


SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.NextReload = 0



/*---------------------------------------------------------
---------------------------------------------------------*/
function SWEP:Initialize()

	if ( SERVER ) then
		self:SetWeaponHoldType( self.HoldType )
	end
end


/*---------------------------------------------------------
	Reload does nothing
---------------------------------------------------------*/
function SWEP:Reload()
	self.Weapon:DefaultReload( ACT_VM_RELOAD );
end


/*---------------------------------------------------------
   Think does nothing
---------------------------------------------------------*/
function SWEP:Think()	
end


/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
SWEP.nextFire = 0
SWEP.lastFire = 0
function SWEP:PrimaryAttack()
	
	
	
	
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


/*---------------------------------------------------------
	Checks the objects before any action is taken
	This is to make sure that the entities haven't been removed
---------------------------------------------------------*/
function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
end

SWEP.NextSecondaryAttack = 0
/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
end


function SWEP:OnDrop()
	self:Remove()
end

/*---------------------------------------------------------
	DrawHUD
	
	Just a rough mock up showing how to draw your own crosshair.

---------------------------------------------------------*/

function SWEP:DoDrawCrosshair( x, y )

  local x = ScrW() / 2.0
  local y = ScrH() / 2.0
  local cone = self.Primary.Cone
  if self.Owner:Crouching() then
    cone = cone * 0.6
  end
  local scale = 10 * cone

  -- Scale the size of the crosshair according to how long ago we fired our weapon
	local LastShootTime = self.lastFire
	scale = scale * (2 - math.Clamp( (CurTime() - LastShootTime) * 5, 0.0, 1.0 ))
	local gap = 40 * scale
	local length = gap + GetConVar( "fw_crosshairlength" ):GetString() * scale
  
  local drawColor = Color( 0, 255, 0, 255 )
  if ConVarExists( "fw_crosshaircolor" ) then
    local colorTbl = string.Explode( " ", GetConVar( "fw_crosshaircolor" ):GetString() )
    drawColor = Color( colorTbl[1], colorTbl[2], colorTbl[3], colorTbl[4] )
  end
  
  local CHWidth = 1 -- Crosshair width
  if ConVarExists( "fw_crosshairwidth" ) then
    CHWidth = GetConVar( "fw_crosshairwidth" ):GetString()
  end
 
  surface.SetDrawColor( drawColor )
  
  surface.DrawRect( x - length - gap, y - CHWidth / 2 , length, CHWidth ) -- Left
  surface.DrawRect( x + gap, y - CHWidth / 2, length, CHWidth ) -- Right
  surface.DrawRect( x - CHWidth / 2, y - length - gap, CHWidth, length ) -- Top
  surface.DrawRect( x - CHWidth / 2, y + gap, CHWidth, length ) -- Bottom
  
  if ConVarExists( "fw_crosshairdot" ) then
    if GetConVar( "fw_crosshairdot" ):GetBool() then
      draw.RoundedBox( 1, x-2, y-2, 3, 3, drawColor )
    end 
  end
  
  return true --hide default crosshair
  
end

/*---------------------------------------------------------
function SWEP:DoDrawCrosshair( x, y )
	local x = ScrW() / 2.0
	local y = ScrH() / 2.0
	local cone = self.Primary.Cone
	if self.Owner:Crouching() then cone = cone * 0.6 end
	local scale = 10 * cone
	
	
	// Scale the size of the crosshair according to how long ago we fired our weapon
	local LastShootTime = self.lastFire
	scale = scale * (2 - math.Clamp( (CurTime() - LastShootTime) * 5, 0.0, 1.0 ))
	local gap = 40 * scale
	local length = gap + GetConVar( "fw_crosshairsize" ):GetString() * scale
	
	local drawColor = Color( 0, 255, 0, 255 )
	if ConVarExists( "fw_crosshaircolor" ) then
    local colorTbl = string.Explode( " ", GetConVar( "fw_crosshaircolor" ):GetString() )
    drawColor = Color( colorTbl[1], colorTbl[2], colorTbl[3], colorTbl[4] )
  end
	
	 surface.SetDrawColor( drawColor )
	
	surface.DrawLine( x - length, y, x - gap, y )
	surface.DrawLine( x + length, y, x + gap, y )
	surface.DrawLine( x, y - length, x, y - gap )
	surface.DrawLine( x, y + length, x, y + gap )
	
	return true
end



	onRestore
	Loaded a saved game (or changelevel)
---------------------------------------------------------*/
function SWEP:OnRestore()

	self.NextSecondaryAttack = 0
	self:SetIronsights( false )
	
end
