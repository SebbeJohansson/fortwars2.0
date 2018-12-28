if SERVER then
  AddCSLuaFile("shared.lua")
end

if CLIENT then
  SWEP.PrintName = "Super Shotty"
  SWEP.Author  = "Darkspider"
  SWEP.Slot = 1
  SWEP.SlotPos = 1
end

SWEP.Base        = "darkland_base"
SWEP.HoldType = "shotgun"
SWEP.Spawnable      = true
SWEP.AdminSpawnable    = true

SWEP.ViewModel      = "models/weapons/v_shot_m3super90.mdl"
SWEP.WorldModel      = "models/weapons/w_shot_m3super90.mdl"
SWEP.Weight        = 5
SWEP.AutoSwitchTo    = false
SWEP.AutoSwitchFrom    = false

SWEP.Primary.Sound      = Sound("Weapon_M3.Single")
SWEP.Primary.Recoil      = 2
SWEP.Primary.Damage      = 4
SWEP.Primary.NumShots    = 10
SWEP.Primary.Cone      = 0.175
SWEP.Primary.ClipSize    = 6
SWEP.Primary.Delay      = 1.0
SWEP.Primary.DefaultClip  = SWEP.Primary.ClipSize * 9999
SWEP.Primary.Automatic    = false
SWEP.Primary.Ammo      = "BuckShot"

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic  = false
SWEP.Secondary.Ammo      = "none"
SWEP.Secondary.Delay    = 5
SWEP.Secondary.Cone        = 0.05
SWEP.Secondary.NumShots    = 4
SWEP.Secondary.Recoil    = 1
SWEP.Secondary.Damage    = 1

--SWEP.NextSecond = 0
if CLIENT then NextShotty = 0 end

function SWEP:Initialize()
  self.Owner.JugSpecial = false
  self:SetHoldType( self.HoldType )
end

--RIPPED OUT OF THE CSS GUN, I DID NOT MAKE THIS
function SWEP:Reload()
  if self:GetNetworkedBool("reloading") then return end
  
  if self:Clip1() < self.Primary.ClipSize && self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
    self:SetNetworkedBool( "reloading", true )
    self:SetVar( "reloadtimer", CurTime() + 0.3 )
    self:SendWeaponAnim( ACT_VM_RELOAD )
  end
end

function SWEP:PrimaryAttack()
  if self:GetNetworkedBool("reloading") then return end
  self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
  self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
  
  self.Owner.NextShotty = self.Owner.NextShotty or 0
  if SERVER and self.Owner.NextShotty > CurTime() then return end
  if CLIENT and NextShotty > CurTime() then return end
  self.Owner.JugSpecial = false
  
  -- Play shoot sound
  self:EmitSound( self.Primary.Sound )
  self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )     -- View model animation
  self.Owner:MuzzleFlash()                -- Crappy muzzle light
  self.Owner:SetAnimation( PLAYER_ATTACK1 )        -- 3rd Person Animation
  -- Shoot the bullet
  self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone )
  
  -- Remove 1 bullet from our clip
  self:TakePrimaryAmmo( 1 )
  
  -- Punch the player's view
  self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
  NextShotty = CurTime() + 0.8
  self.Owner.NextShotty = CurTime() + 0.8
  self:SetNetworkedFloat( "LastShootTime", CurTime() )
  
  if self:Clip1() < 1 then
    self:Reload()
  end
end

function SWEP:SecondaryAttack()
if SERVER then
	if !(self.Owner:Energy() >= 100) or !self.Owner:HasSpecial(7) then return end 
  
    self.Owner:TakeEnergy(100)
  

  self:EmitSound( self.Primary.Sound )
  self:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) -- View model animation
  self.Owner:MuzzleFlash()                    -- Crappy muzzle light
  self.Owner:SetAnimation( PLAYER_ATTACK1 )   -- 3rd Person Animation
  self.Owner.JugSpecial = true
  self:CSShootBullet( self.Secondary.Damage, self.Secondary.Recoil, self.Secondary.NumShots, self.Secondary.Cone )
  end
end

function SWEP:Think()
  if ( self:GetNetworkedBool( "reloading", false ) ) then
    if ( self:GetVar( "reloadtimer", 0 ) < CurTime() ) then
      -- Finsished reload -
      if ( self:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 ) then
        self:SetNetworkedBool( "reloading", false )
        return
      end
      
      -- Next cycle
      self:SetVar( "reloadtimer", CurTime() + 0.3 )
      self:SetVar( "reloadtimer", CurTime() + 0.3 )
      self:SendWeaponAnim( ACT_VM_RELOAD )
      
      -- Add ammo
      self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false )
      self:SetClip1(  self:Clip1() + 1 )
      
      -- Finish filling, final pump
      if ( self:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 ) then
        self:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
      else
      
      end  
    end
  end
end