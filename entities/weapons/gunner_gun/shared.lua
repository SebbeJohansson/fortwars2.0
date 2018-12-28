if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Deathly Deagle"
	SWEP.Author	= "Darkspider"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
end

SWEP.Base				= "darkland_base"
SWEP.Spawnable			= true
SWEP.HoldType = "pistol"
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_pist_deagle.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_deagle.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("Weapon_Deagle.Single")
SWEP.Primary.Recoil			= 2.0
SWEP.Primary.Damage			= 20
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.0175
SWEP.Primary.ClipSize		= 8
SWEP.Primary.Delay			= 0.25
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 9999
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "pistol"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:Deploy()
  local c = self.Owner:GetColor()
  self.Owner:SetColor(Color(c.r, c.g, c.b, 255))
  return true
end

function SWEP:OnRemove()
  if !IsValid(self.Owner) then return end
  local c = self.Owner:GetColor()
  self.Owner:SetColor(Color(c.r, c.g, c.b, 255))
end
function SWEP:Holster()
  local c = self.Owner:GetColor()
  self.Owner:SetColor(Color(c.r, c.g, c.b, 255))
  return true
end

function SWEP:Think()
if SERVER then

  if !IsValid(self.Owner) or !self.Owner:HasSpecial(2) then return end
  
  self.Owner:SetRenderMode(RENDERMODE_TRANSALPHA)
  
  local c = self.Owner:GetColor()
  if self.Owner:GetNWInt("energy") > 0 then
    self.Owner:SetColor(Color(c.r, c.g, c.b, 125))
  else
    self.Owner:SetColor(Color(c.r, c.g, c.b, 255))
	end
  end
end