SWEP.HoldType         = "rpg"

if ( CLIENT ) then
 
  SWEP.PrintName        = "Pumpkin Launcher"   
  SWEP.Author           = "Microbe"
  SWEP.Slot             = 1
  SWEP.SlotPos          = 1
  SWEP.ViewModelFOV     = 55
  SWEP.IconLetter       = ""
  SWEP.DrawAmmo         = false
  SWEP.CSMuzzleFlashes  = false
  SWEP.DrawCrosshair    = false
  killicon.AddFont( "weapon_antitank", "CSKillIcons", SWEP.IconLetter, Color( 0, 255, 0, 255 ) )
 
end
------------General Swep Info---------------
SWEP.Author   = "Microbe"
SWEP.Contact        = ""
SWEP.Spawnable      = true
SWEP.AdminSpawnable = true
SWEP.Delay = 2
SWEP.Primary.Sound  = "darkland/fortwars/pumpkinlaunch.wav"
-----------------------------------------------
 
------------Models---------------------------
SWEP.ViewModelFlip      = false
SWEP.ViewModel      = "models/weapons/v_rpg.mdl"
SWEP.WorldModel   = "models/weapons/w_rocket_launcher.mdl"
SWEP.Base = "darkland_base"
----------------------------------------------
function SWEP:Initialize()
  self.lastSound = CurTime()
end

function SWEP:ResetReload()
self.reloadtimer = 1
end

function SWEP:Deploy()
  return true
end

function SWEP:ResetReload()
self.reloadtimer = 1
end

function SWEP:Reload()
if ( CLIENT ) then return end
--if self.Owner:GetVelocity():Length() > 150 then return end
if !self.Owner:IsOnGround() then return end
if self.reloadtimer == 1 then
self.reloadtimer = 0
timer.Simple( 0.5, self.ResetReload, self ) 
self.Owner:SetMoveType(MOVETYPE_NONE)
end
end

function SWEP:myReload()
  if !self.Weapon then return end
  self:SendWeaponAnim( ACT_VM_RELOAD )
  self:SetNextPrimaryFire( CurTime() + self.Delay )
end

local NextRocket = 0
function SWEP:PrimaryAttack()
  self.Owner.NextRocket = self.Owner.NextRocket  or 0
  if self.Owner.NextRocket > CurTime() then return end
  local spos = self.Owner:GetShootPos()
  local aim = self.Owner:GetAimVector()
  local pos = spos + (aim * 50)
  local tr = {}
  tr.start = spos
  tr.endpos = pos
  tr.filter = self.Owner
  tr = util.TraceLine(tr)
  if tr.Hit then self:EmitSound( "Weapon_RPG.Empty" ) return end
  self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
  if SERVER then
    self:pumpkin()    
  else
    self.Owner:EmitSound( self.Primary.Sound )
  end
  self:SetNextPrimaryFire( CurTime() + self.Delay )
  NextRocket = CurTime() + self.Delay
  self.Owner.NextRocket = CurTime() + self.Delay
  
  //timer.Simple( 1.3, function() self.myReload end )
  
end