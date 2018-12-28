if SERVER then AddCSLuaFile("shared.lua") end
SWEP.Author			= "Darkspider"
SWEP.Contact		= ""
SWEP.Purpose		= "Removes Props"
SWEP.Instructions	= "Shoot to remove props"
SWEP.PrintName = "Prop Remover"
SWEP.Slot = 1
SWEP.SlotPos = 3
SWEP.ViewModelFOV	= 60
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_crossbow.mdl"
SWEP.WorldModel		= "models/weapons/w_crossbow.mdl"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.ClipSize		= -1				// Size of a clip
SWEP.Primary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Primary.Automatic		= false				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1				// Size of a clip
SWEP.Secondary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Secondary.Automatic	= false				// Automatic/Semi Auto
SWEP.Secondary.Ammo			= "none"


function SWEP:PrimaryAttack()
	if CLIENT then return end
	tr = self.Owner:GetEyeTrace()
	if !tr.Entity:IsValid() then return end
	if tr.Entity:GetClass() == "prop" && (tr.Entity.Spawner == self.Owner || self.Owner:IsAdmin())  then

	 local ent = tr.Entity
	 self.Owner:AddMoney(ent.TBL.PRICE)
	 self.Owner.ProppedMoney = self.Owner.ProppedMoney - ent.TBL.PRICE
	 LowerBoxCount(ent.Team)
	 ent:Remove()
	 
	end
end

function SWEP:SecondaryAttack()

end