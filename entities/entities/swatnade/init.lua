AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
    self.Entity:SetModel( "models/items/ar2_grenade.mdl" )
    self.Entity:PhysicsInit( SOLID_VPHYSICS )
    self.Entity:SetMoveType(  MOVETYPE_VPHYSICS )   
    self.Entity:SetSolid( SOLID_VPHYSICS )	
	
	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	util.SpriteTrail(self, 0, team.GetColor(self.LastHolder:Team()), false, 4, 4, 0.5, 1, "trails/plasma.vmt")
	//self:SetCollisionGroup(COLLISION_GROUP_NONE)
end

function ENT:PhysicsCollide( data, phys )
	self:Explode()
end

function ENT:Explode()

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
			width = 10
			
			if ent:IsPlayer() then
				entpos = ent:GetPos()+Vector(0,0,height)
			else
				entpos = ent:GetPos()
			end
			
			
				--target pos	--nade pos
			dis = entpos:Distance(pos)
			
			local trace = { start = pos, endpos = entpos, filter = self.Entity }
			local tr = util.TraceLine( trace )
			
				if tr.Entity == ent and tr.Entity:IsPlayer() then
					if self.LastHolder == tr.Entity then							
						if dis <= 175 and dis >= 35 then
							ent:TakeDamage( (155) - (dis/1.47), self )
						elseif dis < 35 then
							ent:TakeDamage(130, self)
						end
					else
							
						if dis <= (175+width) and dis >= (35+width) then
						
							ent:TakeDamage( (155+width) - (dis/1.47), attacker )	
							
						elseif dis < (35+width) then		
						
							ent:TakeDamage(130, attacker)
							
						end
						
					end
				
				elseif tr.Entity == ent then
					ent:TakeDamage( ((300-dis)/300)*150, self.LastHolder )
				end
			end
		end

	local effectdata = EffectData()
	effectdata:SetStart( pos )
	effectdata:SetOrigin( pos )
	effectdata:SetScale( 8 )
	util.Effect( "Explosion", effectdata )
	self:Remove()

end


function ENT:UpdateTransmitState() 
	return TRANSMIT_ALWAYS 
end

function ENT:OnTakeDamage(dmginfo)
end