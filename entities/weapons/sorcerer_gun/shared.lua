if ( CLIENT ) then
	SWEP.DrawCrosshair		= false
	SWEP.PrintName		= "Divine Power"			
	SWEP.Author		= "Darkspider"
	SWEP.Slot		= 1
	SWEP.SlotPos		= 1
	SWEP.Description	= ""
	SWEP.Purpose		= ""
	SWEP.Instructions	= ""
end
	
function SWEP:DrawHUD()
	local x = ScrW() / 2
	local y = ScrH() / 2
 
	surface.SetDrawColor( 0, 255, 0, 255 )
 
	local gap = 3
	local length = gap + 5
 
	surface.DrawLine( x - length, y, x - gap, y )
	surface.DrawLine( x + length, y, x + gap, y )
	surface.DrawLine( x, y - length, x, y - gap )
	surface.DrawLine( x, y + length, x, y + gap )
end

SWEP.Spawnable			= true
SWEP.HoldType			= "revolver"
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_stunbaton.mdl"
SWEP.WorldModel			= "models/weapons/w_stunbaton.mdl"

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Recoil		= 0.001
SWEP.Primary.Damage		= 0
SWEP.Primary.NumShots		= 0
SWEP.Primary.Cone		= 0
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay		= 0.2
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		= "none"

SWEP.Secondary.Delay		= 1
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end