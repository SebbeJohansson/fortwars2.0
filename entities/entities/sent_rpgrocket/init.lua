AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

local RocketSpeed     = 1400
local PingRadius     = 2800 
local PingRate       = 0.2
local WobbleScale     = 0.003 --0.03 
local TargetAffinity  = 1.07
local GraceTime     = 0.2 --0.6 


function ENT:Initialize()
  self.Entity:SetModel( "models/Weapons/w_missile_closed.mdl" )
  self.Entity:PhysicsInit( SOLID_VPHYSICS )
  self.Entity:SetMoveType(  MOVETYPE_VPHYSICS )   
  self.Entity:SetSolid( SOLID_VPHYSICS )
  self.SpawnTime = CurTime()
  self:EmitSound("darkland/rocket_launcher.mp3")
  self.PhysObj = self.Entity:GetPhysicsObject()
    if (self.PhysObj:IsValid()) then
    self.PhysObj:EnableGravity( false )
    self.PhysObj:EnableDrag( false ) 
    self.PhysObj:SetMass(30)
        self.PhysObj:Wake()
    end
    
  util.PrecacheSound( "explode_4" )
  self.shadowParams = {}
  self.CurrentAngle = self.Entity:GetAngles()
  
  self.NextPing = CurTime() + GraceTime

  self.LastWobble = self.Entity:GetForward()
  
  if self:IsValid() then
  timer.Simple(.1, function()
	self:GetOwner():SetNWBool("activerocket", true) 
  end)
  end
  
  
end

function ENT:Think() 
  local phys = self.Entity:GetPhysicsObject()
  local ang = self.Entity:GetForward() * 9000
  local upang = self.Entity:GetUp() * math.Rand(700,1000) * (math.sin(CurTime()*30))
  local rightang = self.Entity:GetRight() * math.Rand(700,1000) * (math.cos(CurTime()*30))
  if self.superRocket then -- is it a super rocket ?
    --phys:ApplyForceCenter(self.Entity:GetForward() * 27000 * (math.sin(CurTime()*60)))
    local trace = self:GetOwner():GetEyeTrace()
    
    -- Taken from Homing RPG-7 by Lexi - http:--www.garrysmod.org/downloads/?a=view&id=78850
    local Wobble = (VectorRand() + self.LastWobble):GetNormalized()
    local RocketAng = self.Entity:GetForward()
    local NewAng = Wobble*WobbleScale + RocketAng
    local Displacement = (trace.HitPos - self:GetPos())
    NewAng = NewAng*(Displacement:Length()/PingRadius) + Displacement:GetNormalized()*TargetAffinity 
    NewAng = NewAng:GetNormalized()

    self.Entity:SetAngles(NewAng:Angle())
    self.PhysObj:AddVelocity(NewAng*RocketSpeed)
    self.LastWobble = Wobble
  else
    if self.SpawnTime + 0.5 < CurTime() then
      --if superRocket then ang = self:GetOwner():GetEyeTrace().HitPos end
      phys:ApplyForceCenter(ang + upang + rightang)
    else
      phys:ApplyForceCenter(self.Entity:GetForward() * 9000)
    end    
  end
end


function ENT:Explosion(vel)

	if !self then return end

	local attacker = self.LastHolder
	if !IsValid(attacker) then
		attacker = self
	end

	local height, entpos, dis;
	local pos = self.Entity:GetPos()
	local others = ents.FindInSphere( self.Entity:GetPos(), 300  )
		for _, ent in pairs( others ) do
			height = 0
		if IsValid(ent) then
			height = 50
			width = 16
			
			if ent:IsPlayer() then
				entpos = ent:GetPos()+Vector(0,0,height)
			else
				entpos = ent:GetPos()
			end
			
			dis = entpos:Distance(pos)
			
			local trace = { start = pos, endpos = entpos, filter = self.Entity }
			local tr = util.TraceLine( trace )
			
				if tr.Entity == ent and tr.Entity:IsPlayer() then
				
					if self.LastHolder == tr.Entity then
								
						if dis <= 225 and dis >= 75 then
							ent:TakeDamage( 300-dis, self )
						elseif dis < 75 then
							ent:TakeDamage(150, self)
						end
			
					else
							
						if dis <= (200+width) and dis >= (50+width) then						
							ent:TakeDamage( 200-dis, attacker )							
						elseif dis < (50+width) then						
							ent:TakeDamage(150, attacker)							
						end
						
					end
				
				elseif tr.Entity == ent then
					ent:TakeDamage( (	(300-dis)/300	)*200 , self.LastHolder )
				end
			end
		end
	local effectdata = EffectData()
	effectdata:SetOrigin( self.Entity:GetPos() )
	effectdata:SetNormal(vel)
	util.Effect( "rocketman", effectdata )
	
end

function ENT:PhysicsUpdate( phys )
	phys:AddVelocity( self.Entity:GetForward() * 1.1 );
end 
   
function ENT:PhysicsCollide( data, physobj )

	self:GetOwner():SetNWBool("activerocket", false) 
 
	util.Decal("Scorch", data.HitPos + data.HitNormal , data.HitPos - data.HitNormal)
	local p = data.HitEntity
	local v = physobj:GetVelocity()
	
	if p:IsPlayer() and p:Team() !=  self.LastHolder:Team() then p:Gib(v) end
	
	self:Explosion(v)
	
	self.Entity:Remove()
end

function ENT:OnRemove()
	self:GetOwner():SetNWBool("activerocket", false) 
	self.Entity:StopSound( "explode_4" )
end
function ENT:KeyValue( ent, key )
end

function ENT:UpdateTransmitState( ent )
	return TRANSMIT_ALWAYS
end

function ENT:OnTakeDamage(dmginfo)
	local physobj = self:GetPhysicsObject()
	local v = physobj:GetVelocity()
	self:Explosion(v)
	self.Entity:Remove()
end