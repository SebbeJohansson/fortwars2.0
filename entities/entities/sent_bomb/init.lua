AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
  self.Entity:SetModel( "models/weapons/w_c4.mdl" )
  self.Entity:PhysicsInit( SOLID_VPHYSICS )
  self.Entity:SetMoveType(  MOVETYPE_NONE )   
  self.Entity:SetSolid( SOLID_VPHYSICS )  
  self.health = self.Owner:GetMaxHealth()
  self.maxHealth = self.Owner:GetMaxHealth()
  
  local phys = self.Entity:GetPhysicsObject()
  if phys:IsValid() then
    phys:Wake()
  end
  
  self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
  self.tickRate = 1
  self.maxReps = 8
  self.reps = 8
  
  
  timer.Create("bombtimer", 1, self.maxReps+1, function()
	for k, v in pairs( ents.FindByClass( "sent_bomb" ) ) do
		v.reps = v.reps - 1
		v.tickRate = v.reps / v.maxReps + 0.05
		//print(v:EntIndex().."reps: "..v.reps)
	end
  end)

  
end


function ENT:UpdateTransmitState() 
  return TRANSMIT_PVS
end

function ENT:Think()
	if self.reps < 1 then
		self:Explode()
	end

	self:EmitSound("HL1/fvox/beep.wav")
	self:NextThink(CurTime() + self.tickRate)
	return true
end


function ENT:Explode()
  //if self.reps < 1 then
    local height, entpos, dis;
    local pos = self.Entity:GetPos()
    local others = ents.FindInSphere( self.Entity:GetPos(), 300  )
    for _, ent in pairs( others ) do
      height = 0
    if IsValid(ent) then
      if ent:IsPlayer() then
        if ent:Crouching() then
          height = 30
        else
          height = 50
        end
      end
      entpos = ent:GetPos()+Vector(0,0,height)
      dis = entpos:Distance(pos)
      
      local trace = { start = pos, endpos = entpos, filter = self.Entity }
      local tr = util.TraceLine( trace )
      
        if tr.Entity == ent and tr.Entity:IsPlayer() and (tr.Entity:Team() != self:GetOwner():Team() or tr.Entity == self.LastHolder) or tr.Entity == self:GetOwner() then
          if self.Entity:GetOwner() != ent then
            ent:TakeDamage( ((300 - dis)/300)*150 , self.Entity:GetOwner(), self )
          else
            ent:TakeDamage( ((300 - dis)/300)*150 , game.GetWorld(), self )
          end
        elseif tr.Entity == ent and tr.Entity.TBL then -- prop
          if tr.Entity.Team == self:GetOwner():Team() then
            ent:TakeDamage( ((300 - dis)/300)*250 , self.Entity:GetOwner(), self )
          else
            ent:TakeDamage( ((300 - dis)/300)*250 , self.Entity:GetOwner(), self )
          end
        end
      end
    end
    local effectdata = EffectData()
    effectdata:SetStart( self:GetPos() )
    effectdata:SetOrigin( self:GetPos() )
    effectdata:SetScale( 8 )
    util.Effect( "Explosion", effectdata )
    self:Remove()
  //end
  
end

function ENT:OnTakeDamage(dmg)


  if dmg:GetAttacker():Team() == self.Entity:GetOwner():Team() then return end

  self.health = self.health - dmg:GetDamage()
  
  if self.health <= 0 then
    self:Remove()
  end
end