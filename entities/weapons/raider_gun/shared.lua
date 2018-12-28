if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "MAC10"
	SWEP.Author	= "Darkspider"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
end

SWEP.Base				= "darkland_base"
SWEP.HoldType = "smg"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_smg_mac10.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_mac10.mdl"
SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound("Weapon_mac10.Single")
SWEP.Primary.Recoil			= 0.4
SWEP.Primary.Damage			= 9
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.035
SWEP.Primary.ClipSize		= 25
SWEP.Primary.Delay			= 0.08
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
	self.Owner:SetNWBool( "canrun", true )
end

function SWEP:Deploy()
	self.Owner:SetNWBool( "raidrunning", false )
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	
	return true
end

function SWEP:Think()
	if SERVER then
	
	local index = tonumber(self.Owner:GetPData("Class"))
	local oldspeed = Classes[index].SPEED
	
	if (self.Owner:HasSpecial(17)) then	
	if self.Owner:GetNWInt('energy') <= 0 then	
		self.Owner:SetNWBool( "raidrunning", false )
		self.Owner:SetNWBool( "canrun", true )
		
		self.Owner.nextrun = CurTime() + 5

		if IsValid(self.Owner) then
			timer.Simple(5, function() self.Owner:SetNWBool( "canrun", false ) end )
		end
		
			

		net.Start("cooldown")
			net.WriteInt(self.Owner.nextrun, 32)
		net.Send(self.Owner)
		
	end
	
	if self.Owner:GetNWBool( "raidrunning" ) == true then
		self.Owner:SetWalkSpeed((oldspeed + Skills[1].LEVEL[self.Owner.upgrades[1]]) * 3)
	else
		self.Owner:SetWalkSpeed( oldspeed + Skills[1].LEVEL[ self.Owner.upgrades[1] ])
	end
		end
	end
end


function SWEP:Holster(wep)
	if SERVER then
	
	local index = tonumber(self.Owner:GetPData("Class"))
	local oldspeed = Classes[index].SPEED
	
	if self.Owner:GetNWBool( "raidrunning" ) == true then
		self.Owner:SetNWBool( "raidrunning", false )
		self.Owner:SetWalkSpeed( oldspeed + Skills[1].LEVEL[ self.Owner.upgrades[1] ])
		self.Weapon:SetNextSecondaryFire(CurTime() + 5)
	end
	
	return true
	end
end

function SWEP:SecondaryAttack()
	if self.Owner:GetNWBool( "canrun" ) == true then return end
	
	if SERVER then
		if (self.Owner:HasSpecial(17)) then
	
	------------
	-- If you are not already sprinting and are eligable to do so...
	-----------
	
	
	if self.Owner:GetNWBool( "raidrunning" ) == false and (self.Owner:GetNWInt('energy')) > 0 then --not already running and energy above 0
		self.Owner:SetNWBool( "cancancel", false )
		timer.Simple(1, function() self.Owner:SetNWBool( "cancancel", true ) end )
		self.Owner:SetNWBool( "raidrunning", true )
		self.Owner:EmitSound("HL1/fvox/morphine_shot.wav", 100, 100)
		
	elseif self.Owner:GetNWBool( "raidrunning" ) == true and self.Owner:GetNWBool( "cancancel" ) == true  then -- already running and can cancel
		
			self.Owner:SetNWBool( "raidrunning", false)
			self.Owner:SetNWBool( "cancancel", false)
			self.Weapon:SetNextSecondaryFire( CurTime()+5 )
			
		net.Start("cooldown")
			net.WriteInt(self.Weapon:GetNextSecondaryFire(), 32)
		net.Send(self.Owner)

	end
		
	else
		self.Owner:ChatPrint("You do not own this special ability!")
		
	end
	
	elseif CLIENT then
	
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
	self.Owner:SetNWBool( "canrun", false )
end