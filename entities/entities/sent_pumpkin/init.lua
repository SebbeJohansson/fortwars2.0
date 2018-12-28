
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:Initialize()
  self.health = 30
  self.Entity:SetModel( "models/roller.mdl" )
  self.Entity:PhysicsInit( SOLID_VPHYSICS )
  self.Entity:SetMoveType(  MOVETYPE_VPHYSICS )   
  self.Entity:SetSolid( SOLID_VPHYSICS )  
  util.SpriteTrail(self,CurTime(),Color(255,255,255,255), false, 15, 1, 2, 1/(15+1)*0.5, "darkland/fortwars/yellowglow1.vmt")
  self.potentialTargets = {}
  self.initPos = self.Entity:GetPos()
  self.phys = self.Entity:GetPhysicsObject()
  if self.phys:IsValid() then
    self.phys:Wake()
    self.phys:EnableGravity(false)
    self.phys:SetMass(1)
  end
  
  self:launch()
  timer.Simple(1.5,function() if IsValid(self) then self:findTarget() end end)

end

function ENT:PhysicsCollide(data, physobj)
  if IsValid(data.HitEntity) and data.HitEntity:IsPlayer() then
    data.HitEntity:TakeDamage( 30, self.Entity:GetOwner(), self )
    if IsValid(self:GetOwner()) and self:GetOwner():Alive() and self:GetOwner():GetNWInt('energy') >= 50 then
      local ent = ents.Create("sent_pumpkin")
      ent:SetPos(self:GetOwner():GetPos())
      ent:SetOwner(self:GetOwner())
      ent.Team = self.Team
      ent.Owner = self.Owner // The weapon is the owner
      ent:SetAngles( self:GetOwner():EyeAngles() )
      self:GetOwner():TakeEnergy(50)
      ent.LastHolder = self:GetOwner()
      ent:Spawn()
      
      //if IS_CHRISTMAS then
      // ent:EmitSound("darkland/fortwars/hohoho.wav")
      //else
        ent:EmitSound("darkland/fortwars/witchlaugh.wav")
      //end
    end
  end
  self:Remove()
end

function ENT:launch()
  //self.Entity:SetMoveType(  MOVETYPE_VPHYSICS )
  self:SetPos(self:GetOwner():GetShootPos())
  self.phys:AddVelocity(self:GetOwner():GetAimVector()*1000)

end

function ENT:findTarget()
  local height
  local pos = self:GetPos()
  local others = ents.FindInSphere( pos, 500  )
  
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
      local trace = { start = pos, endpos = ent:GetPos()+Vector(0,0,height), filter = self.Entity }
      local tr = util.TraceLine( trace )
      if tr.Entity == ent and tr.Entity:IsPlayer() and tr.Entity:Team() != self.Team and !tr.Entity:GetNWBool("invis") then
        table.insert(self.potentialTargets, tr.Entity)    
      end
    end
  end
  
  
  if table.Count(self.potentialTargets) < 1 then
    timer.Simple(1.5, function() if IsValid(self) then self:findTarget() end  end)
  else
    self.target = self.potentialTargets[math.random(1,#self.potentialTargets)] 
    //if IS_CHRISTMAS then
    //  self:EmitSound("darkland/fortwars/hohoho.wav")
    //else
      self:EmitSound("darkland/fortwars/pumpkin.wav")
   // end
  end
  
end

function ENT:Think()
  if IsValid(self.target) and self.target:Alive() then
    local height = 30
    if !self.target:Crouching() then
      height = 50
    end
    self:SetAngles( ( ( self.target:GetPos()+ Vector(0,0,height) ) - self:GetPos() ):Angle())
    self.phys:SetVelocity(self:GetForward()*750) // go 2x faster if you have a target
  else
    self.phys:SetVelocity(self:GetForward()*500)
  end
  
  if !Distance( self.initPos, self.phys:GetPos(), 2000) and table.Count(self.potentialTargets) < 1 then --self.initPos:Distance(self.phys:GetPos()) > 3000 and 
    self:Remove()
  end
end

/*---------------------------------------------------------
  More efficient way of seeing if two positions are less
  than a certain distance apart.  
---------------------------------------------------------*/
function Distance(pos1, pos2, distance)
  if ((pos1.x - pos2.x)^2 + (pos1.y - pos2.y)^2 + (pos1.z - pos2.z)^2) < (distance^2) then
    return true
  else 
    return false
  end
end

function ENT:OnTakeDamage(dmg)
  self.health = self.health - dmg:GetDamage()
  
  if self.health <= 0 then
    self:Remove()    
  end
end
