if ( SERVER ) then
    AddCSLuaFile( "shared.lua" )
end
 
if ( CLIENT ) then
	SWEP.Primary.Sound = Sound("rocket_launcher.mp3")
    SWEP.PrintName     		= "Rocket Launcher"   
    SWEP.Author    			= "Protocol7"
 
    SWEP.Slot           	= 2
    SWEP.SlotPos        	= 1
    SWEP.ViewModelFOV   	= 55
    SWEP.IconLetter   	 	= ""
	SWEP.DrawAmmo			= false
	SWEP.CSMuzzleFlashes	= false
	SWEP.DrawCrosshair 		= false
	killicon.AddFont( "weapon_antitank", "CSKillIcons", SWEP.IconLetter, Color( 0, 255, 0, 255 ) )
 
end
------------General Swep Info---------------
SWEP.Author   = "Protocol7"
SWEP.Contact        = ""
SWEP.HoldType         = "rpg"
SWEP.Spawnable      = true
SWEP.AdminSpawnable = true
SWEP.Primary.Sound = Sound("rocket_launcher.mp3") 
SWEP.Delay = 2
-----------------------------------------------
 
------------Models---------------------------
SWEP.ViewModelFlip	    = false
SWEP.ViewModel      = "models/weapons/v_rpg.mdl"
SWEP.WorldModel   = "models/weapons/w_rocket_launcher.mdl"
SWEP.Base = "darkland_base"
----------------------------------------------

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
	self.Weapon.superRockets = 0
end

function SWEP:Deploy()
  self.Weapon.superRockets = 0
  return true
end

function SWEP:Precache()
	util.PrecacheSound("rocket_launcher.mp3")
end

function SWEP:Rocket(superRocket)
if SERVER then

  local spos = self.Owner:GetShootPos()
  local aim = self.Owner:GetAimVector()
  local pos = spos + (aim * 50)
  pos = pos + (self.Owner:GetRight() * 10)
  
  local rocket = ents.Create( "sent_rpgrocket" )  
  
  rocket:SetOwner( self.Owner )
  rocket.superRocket = superRocket
  rocket.Owner = self // The weapon is the owner
  rocket.LastHolder = self.Owner
  rocket:SetPos( pos )
  rocket:SetAngles( self:GetAngles() )
  rocket:Spawn()
  rocket:Activate()
  
  
  self.Owner:ViewPunch( Angle( math.Rand( 0, -10 ), math.Rand( 0, 0 ), math.Rand( 0, 0 ) ) )
  
  end
end

function SWEP:myReload()
	if !self.Weapon then return end
	self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
	self.Weapon:SetNextPrimaryFire( CurTime() + 2 )
end

local NextRocket = 0
function SWEP:PrimaryAttack()

	 if self.Owner:GetNWBool("activerocket") == true then return end
	 
		self.Weapon:SetNextPrimaryFire( CurTime() + 4 )

		local spos = self.Owner:GetShootPos()
		local aim = self.Owner:GetAimVector()
		local pos = spos + (aim * 50)
		local tr = {}
		tr.start = spos
		tr.endpos = pos
		tr.filter = self.Owner
		tr = util.TraceLine(tr)
		if tr.Hit then self.Weapon:EmitSound( "Weapon_RPG.Empty" ) return end
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		
		
		if SERVER then
    if self.superRockets > 0 then
      self:Rocket(true)
    else
      self:Rocket(false)
    end
  end
		timer.Simple(2,function() if IsValid(self) then self.superRockets = self.superRockets - 1 end end )
		///self:Rocket( self.Owner:GetAimVector() )
		
		timer.Simple( 2.2, function()
			if !self.Weapon then return end
		end)
		
end

function SWEP:SecondaryAttack()
if SERVER  then
  if !self.Owner:HasSpecial(15) then 
    self.Owner:ChatPrint("You do not have the special ability for this class. Press F1 and look in the Classes tab to buy it.") 
    return 
  end
  if self.Owner:Energy() >= 100 then
    self.Weapon.superRockets = 1
    if SERVER then
      self.Owner:EmitSound("weapons/slam/mine_mode.wav")
      self.Owner:TakeEnergy(100)
	  end
    end
  end
end

function SWEP:DrawHUD()
if CLIENT then
  if self.Weapon.superRockets > 0 then
  
    local vm = self:GetOwner():GetViewModel()
    local attachmentIndex = vm:LookupAttachment("laser")
    local t = util.GetPlayerTrace(self:GetOwner())
    local tr = util.TraceLine(t)
	
    cam.Start3D(EyePos(), EyeAngles())
	
      render.SetMaterial(Material("sprites/bluelaser1"))
      render.DrawBeam(vm:GetAttachment(attachmentIndex).Pos, tr.HitPos, 2, 0, 12.5, Color(255, 0, 0, 255))
      local Size = math.random() * 1.35
      render.SetMaterial(Material("Sprites/light_glow02_add_noz"))
      render.DrawQuadEasy(tr.HitPos, (EyePos() - tr.HitPos):GetNormal(), Size, Size, Color(255,0,0,255), 0)
	  
    cam.End3D()
	
  end

  
  local x = ScrW() / 2.0
  local y = ScrH() / 2.0  
    
  surface.SetDrawColor( 0, 255, 0, 255 )  
  surface.DrawLine( x - 20, y, x + 20, y  )
  surface.DrawLine( x - 13, y + 5, x + 13, y + 5 )
  surface.DrawLine( x - 7, y + 10, x + 7, y + 10 )
  surface.DrawLine( x - 4, y + 15, x + 4, y + 15 )
  surface.DrawLine( x - 2, y + 20, x + 2, y + 20 )
  end
end


