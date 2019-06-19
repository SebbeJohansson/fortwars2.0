if CLIENT then
	SWEP.PrintName = "Killer Blade"
	SWEP.Author	= "Darkspider"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
	SWEP.DrawCrosshair = true
end

util.PrecacheSound("weapons/knife/knife_hit1.wav")
util.PrecacheSound("weapons/knife/knife_hitwall1.wav")
util.PrecacheSound("weapons/knife/knife_slash1.wav")
util.PrecacheSound("weapons/physcannon/energy_sing_flyby2.wav")

SWEP.Author			= "Darkspider"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.Spawnable			= false
SWEP.HoldType = "melee"
SWEP.AdminSpawnable		= false

SWEP.ViewModel			= "models/weapons/v_knife_t.mdl"
SWEP.WorldModel			= "models/weapons/w_knife_t.mdl"

SWEP.Primary.Damage			= 30
SWEP.Primary.BackStab		= 2000
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.Delay		= 12
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:Initialize()
	self:SetHoldType("melee") --its a knife
end

function SWEP:Deploy()
	self.Owner:SetNWBool( "cloaked", false )
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW)	
	return true
end

function SWEP:Think()
	if SERVER then
	local index = tonumber(self.Owner:GetPData("Class"))
	local oldspeed = Classes[index].SPEED
	
	if (self.Owner:GetNWInt('energy') <= 0) then
		self.Weapon:SetNextSecondaryFire(CurTime() + 5)
	end
	
	if self.Owner:GetNWInt('energy') <= 0 then self.Owner:SetNWBool( "cloaked", false ) end
	if self.Owner:GetNWBool( "cloaked" ) == true then
		self.Owner:SetNoDraw(true)
		self.Owner:SetWalkSpeed(450)
		self.Weapon:SetNoDraw(true)
	else
		self.Owner:SetWalkSpeed( oldspeed + Skills["speed_limit"].LEVEL[ self.Owner.upgrades["speed_limit"] ])
		self.Owner:SetNoDraw(false)
		self.Weapon:SetNoDraw(false)
		end
	end
	if CLIENT then
		if self.Owner:GetNWBool( "cloaked" ) == true then
			LocalPlayer():GetViewModel():SetRenderMode( RENDERMODE_TRANSALPHA )
			LocalPlayer():GetViewModel():SetColor(Color(255, 255, 255, 125))
		else
			LocalPlayer():GetViewModel():SetRenderMode( RENDERMODE_NORMAL )
			LocalPlayer():GetViewModel():SetColor(Color(255, 255, 255, 255))
		end
	end
end

function SWEP:Holster()
if SERVER then

	local index = tonumber(self.Owner:GetPData("Class"))
	local oldspeed = Classes[index].SPEED
	
	if self.Owner:GetNWBool( "cloaked" ) == true then
	
		self.Owner:SetNWBool( "cloaked", false )
		self.Owner:SetNoDraw(false)
		self.Weapon:SetNoDraw(false)
		self.Owner:SetWalkSpeed( oldspeed + Skills["speed_limit"].LEVEL[ self.Owner.upgrades["speed_limit"] ])
		self.Weapon:SetNextSecondaryFire(CurTime() + 5)

	end
		
	return true
	
	end
end

function SWEP:SecondaryAttack()
	if self.Owner:GetNWBool( "cloaked" ) == true then return end
	
	if (self.Owner:GetNWInt('energy') > 0) then
		self.Owner:SetNWBool( "cloaked", true )
	else
		self.Owner:SetNWBool( "cloaked", false )
	end
	self.Weapon:EmitSound(Sound( "weapons/physcannon/energy_sing_flyby2.wav"), 100,120)
end

function SWEP:PrimaryAttack()
	if self.Owner:GetNWBool( "cloaked" ) == true then
		self.Weapon:SetNextSecondaryFire(CurTime() + 5)
	end
	self.Owner:SetNWBool( "cloaked", false )
	self.Weapon:SetNextPrimaryFire(CurTime() + .35)
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	local pos = self.Owner:GetShootPos()
	local dir = self.Owner:GetAimVector()
	local eyetr = self.Owner:GetEyeTrace()
	local tmin = Vector(1, 1, 1)*-10
	local tmax = Vector(1, 1, 1)*10
	
	local vel = self.Owner:GetVelocity()
	local myvel = math.sqrt(vel.x^2 + vel.y^2 + vel.z^2)
	
	local range = 80 + (myvel*.1)
	

	
	local trace = {}
	trace.start = pos
	trace.endpos = pos + (dir * range)
	trace.filter = self.Owner
	trace.mins = tmin
	trace.maxs = tmax
	
	local tr = util.TraceHull(trace)
	if tr.Hit then
	
		self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
			local pos1 = eyetr.HitPos + tr.HitNormal
			local pos2 = eyetr.HitPos - tr.HitNormal
		
		util.Decal("ManhackCut",pos1,pos2)

		if !tr.HitWorld and !tr.Entity:IsPlayer() then
		self.Weapon:EmitSound(Sound("weapons/knife/knife_hitwall1.wav"), 65, 100)
				if !CLIENT then
					tr.Entity:TakeDamage(10,self.Owner)
				end
		elseif !tr.HitWorld and tr.Entity:IsPlayer() then
			self.Weapon:EmitSound(Sound("weapons/iceaxe/iceaxe_swing1.wav"))
				if !CLIENT then
						local y1, y2 = tr.Entity:GetAngles().y, self.Owner:GetAngles().y
						local AngDiff = y1 - y2
						
						if AngDiff <= 60 and AngDiff >= -60 then
							tr.Entity:TakeDamage(self.Primary.BackStab,self.Owner)
						else
							tr.Entity:TakeDamage(self.Primary.Damage,self.Owner)
						end
					end
					
		elseif tr.HitWorld then
			self.Weapon:EmitSound(Sound("weapons/knife/knife_hitwall1.wav"), 65, 100)
		
		end
				
	else
		self.Weapon:EmitSound(Sound("weapons/iceaxe/iceaxe_swing1.wav"))
		self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
	end
end

function SWEP:Reload()
end