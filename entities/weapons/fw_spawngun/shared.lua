if SERVER then AddCSLuaFile("shared.lua") end
SWEP.Author			= "Darkspider"
SWEP.Contact		= ""
SWEP.Purpose		= "Create custom spawn"
SWEP.Instructions	= "Shoot and spawn where you are standing"
SWEP.PrintName = "Spawn Gun"
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.ViewModelFOV	= 60
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_irifle.mdl"
SWEP.WorldModel		= "models/weapons/w_irifle.mdl"

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
SWEP.nextFire = 0
	if SERVER then AddCSLuaFile("shared.lua") end
SWEP.Author    = "Darkspider"
SWEP.Contact    = ""
SWEP.Purpose    = "Create a custom spawnpoint"
SWEP.Instructions  = "Left click to spawn where you are standing. Right click to remove your spawn"
SWEP.PrintName = "Spawn Gun"
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.ViewModelFOV  = 60
SWEP.ViewModelFlip  = false
SWEP.ViewModel    = "models/weapons/v_irifle.mdl"
SWEP.WorldModel    = "models/weapons/w_irifle.mdl"
SWEP.HoldType = "ar2"

SWEP.Spawnable      = true
SWEP.AdminSpawnable    = true

SWEP.Primary.ClipSize    = -1        // Size of a clip
SWEP.Primary.DefaultClip  = -1        // Default number of bullets in a clip
SWEP.Primary.Automatic    = false        // Automatic/Semi Auto
SWEP.Primary.Ammo      = "none"

SWEP.Secondary.ClipSize    = -1        // Size of a clip
SWEP.Secondary.DefaultClip  = -1        // Default number of bullets in a clip
SWEP.Secondary.Automatic  = false        // Automatic/Semi Auto
SWEP.Secondary.Ammo      = "none"
SWEP.nextFire = 0

function SWEP:PrimaryAttack()
  if self.nextFire > CurTime() then return end

  if SERVER then
    if self.Owner:Crouching() and self.Owner:IsOnGround() then
      self.Owner:SendLua([[notification.AddLegacy("You can not set a spawnpoint while crouching", NOTIFY_ERROR, 2) surface.PlaySound("buttons/button10.wav") Msg("You can not set a spawnpoint while crouching\n")]])
      return
    end
    for k, v in pairs(ents.FindByClass("darkland_spawn")) do
      if v:GetOwner():Team() == self.Owner:Team() and v:GetPos():Distance(self.Owner:GetPos()) < 80 and v != self.Owner.SpawnPoint then 
        self.Owner:SendLua([[notification.AddLegacy("There is already a spawnpoint here", NOTIFY_ERROR, 2) surface.PlaySound("buttons/button10.wav") Msg("There is already a spawnpoint here\n")]])
        return true
      end
    end
    for k, v in pairs(ents.FindByClass("spawn_marker")) do
      if v:GetPos():Distance(self.Owner:GetPos()) < 80 then
        self.Owner:SendLua([[notification.AddLegacy("You are too close to a default spawn to set a spawnpoint", NOTIFY_ERROR, 2) surface.PlaySound("buttons/button10.wav") Msg("You are too close to a default spawn to set a spawnpoint\n")]])
        return true
      end
    end
    
    if !IsValid(self.Owner.SpawnPoint) then
      self.Owner.SpawnPoint = ents.Create("darkland_spawn")
      self.Owner.SpawnPoint:SetOwner(self.Owner)
      self.Owner.SpawnPoint:Spawn()
    end
    self.Owner.SpawnPoint:SetPos(self.Owner:GetPos())
    self.Owner.SpawnAng = self.Owner:EyeAngles()
    self.Owner:EmitSound("ambient/machines/catapult_throw.wav")
  end
  self.nextFire = CurTime()+1
  
     local ef = EffectData()
    ef:SetOrigin(self.Owner:GetPos())
    util.Effect("spawngun",ef)

end
function SWEP:SecondaryAttack()
  if CLIENT then return end
  if IsValid(self.Owner.SpawnPoint) then
    self.Owner.SpawnPoint:Remove()
    self.Owner.SpawnPoint = nil
    self.Owner.SpawnAng = nil
    self.Owner:SendLua([[notification.AddLegacy("Spawnpoint Undone", NOTIFY_UNDO, 2) surface.PlaySound("buttons/button15.wav") Msg("Spawnpoint Undone\n")]])
  end
end