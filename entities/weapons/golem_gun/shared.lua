if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "HammerDown"
	SWEP.Author	= "Darkspider"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
end

SWEP.Base				= "darkland_base"
SWEP.HoldType = "ar2"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_mach_m249para.mdl"
SWEP.WorldModel			= "models/weapons/w_mach_m249para.mdl"
SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.ViewModelFlip 		= false
SWEP.Primary.Sound			= Sound("Weapon_M249.Single")
SWEP.Primary.Recoil			= 1.3
SWEP.Primary.Damage			= 10
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.035
SWEP.Primary.ClipSize		= 75
SWEP.Primary.Delay			= 0.07
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize * 9999
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "SMG1"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.Delay		= 1

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
	self.Owner:SetNWBool( "canuse", false ) 
end

function SWEP:SecondaryAttack()
	if SERVER then

	if (self.Owner:HasSpecial(5)) then
	
		if self.Owner:Energy() >= 100 and self.Owner:GetNWBool( "canuse" ) == false  then
		
			self.Owner:TakeEnergy(100)
			self.Owner:EmitSound( "vo/ravenholm/monk_blocked01.wav" )
			self.Owner:SetNWBool("outtamyway", true)
			self.Owner:SetNWBool( "canuse", true )

		if self.Owner:Health() > 0 then
			-- After 4 seconds take normal damage again
			timer.Simple(4, function()
					self.Owner:SetNWBool("outtamyway", false)
					
					
				self.Owner.nextuse = CurTime() + 4
				
				net.Start("cooldown")
					net.WriteInt(self.Owner.nextuse, 32)
				net.Send(self.Owner)
				
				
				-- And 4 seconds after that you can use the ability again
				timer.Simple(4, function()
					self.Owner:SetNWBool("canuse", false) 
				end)
				
			end)
			else return
			end
		end
		
	else
	self.Owner:ChatPrint("You do not own this special ability!")
		end
		
	else
	
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
end

function SWEP:OnRemove()
	self.Owner:SetNWBool( "canuse", false )
end