AddCSLuaFile( "shared.lua" )
include("shared.lua")

SWEP.ManaCost = 40
local seekingSound = Sound("darkland/fortwars/sorcerer_seek.wav")
local chainLightningSound = Sound("darkland/fortwars/chainlightning.wav")

function SWEP:Initialize()
  
end
function SWEP:PrimaryAttack()
  cs = ""
  table.foreach(team.GetColor(self.Owner:Team()), function(k, v) cs = cs..tostring(v).." " end)
  cs = string.Right(cs,string.len(cs)-4)
  
  self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
  if self.Owner:Energy() > self.ManaCost then
    local vStart = self.Owner:GetShootPos()
    local vForward = self.Owner:GetAimVector()
    local trace = {}
    trace.start = vStart
    trace.endpos = vStart + (vForward * 4096) 
    trace.filter = self.Owner
    local tr = util.TraceLine(trace)
    local norm = tr.Normal
    local pos = tr.HitPos
    self:EmitSound(Sound("ambient/energy/weld2.wav"))
    self.Owner:SendLua("surface.PlaySound(\"ambient/energy/weld2.wav\")")
    util.Decal("FadingScorch", pos + norm, pos - norm )
      entend = ents.Create ("info_target")
      entend:SetKeyValue("targetname", "endpos")
      entend:SetPos(pos)
      entend:Spawn()
      pewpew = ents.Create("env_laser")
      pewpew:SetKeyValue("renderamt", "255")
      pewpew:SetKeyValue("rendercolor", "130 175 255") --"20 150 220")
      pewpew:SetKeyValue("texture", "sprites/lgtning_noz.spr")
      pewpew:SetKeyValue("TextureScroll", "50")
      pewpew:SetKeyValue("targetname", "laser" )
      pewpew:SetKeyValue("renderfx", "2")
      pewpew:SetKeyValue("width", "15")
      pewpew:SetKeyValue("damage", "0")
      pewpew:SetKeyValue("NoiseAmplitude", "1")
      pewpew:SetKeyValue("dissolvetype", "1")
      pewpew:SetKeyValue("EndSprite", "")
      pewpew:SetKeyValue("LaserTarget", "endpos")
      pewpew:SetKeyValue("TouchType", "-1")
      pewpew:SetPos(self.Owner:GetShootPos() + Vector(0,0,-2) + self.Owner:GetForward()*20 + self.Owner:GetRight()*13)
      pewpew:Spawn()
      pewpew:Fire("TurnOn", "", 0.001)
      pewpew:Fire("kill", "", 0.2)

      entend:Fire("kill", "", 0.21)
      zap = ents.Create("point_tesla")
      zap:SetKeyValue("targetname", "teslazap")
      zap:SetKeyValue("m_SoundName", "DoSpark")
      zap:SetKeyValue("texture", "sprites/lgtning_noz.spr")
      zap:SetKeyValue("m_Color", "130 175 255")--"20 150 220")
      zap:SetKeyValue("m_flRadius", "200")
      zap:SetKeyValue("beamcount_min", "15")
      zap:SetKeyValue("beamcount_max", "30")
      zap:SetKeyValue("thick_min", "0.1")
      zap:SetKeyValue("thick_max", "0.3")
      zap:SetKeyValue("lifetime_min" ,"0.8")
      zap:SetKeyValue("lifetime_max", "1.5")
      zap:SetKeyValue("interval_min", "0.3")
      zap:SetKeyValue("interval_max" , "0.8")
      zap:SetPos(pos)
      zap:Spawn()
      for i = 1,5 do
        local tim = math.Rand(0.1,0.8)
        zap:Fire("DoSpark","",tim)
      end
      timer.Simple(0.3,function() 
      if IsValid(pewpew) then pewpew:Remove() end
      if IsValid(entend) then entend:Remove() end
      if IsValid(zap) then zap:Remove() end 
      end)
      
      bullet = {}
      bullet.Num=1
      bullet.Src=self.Owner:GetShootPos()
      bullet.Dir=self.Owner:GetAimVector()
      bullet.Spread=Vector(0,0,0)
      bullet.Tracer=0
      bullet.Force=2
      bullet.Damage=70
       
      self.Owner:FireBullets(bullet)
      self.Owner:TakeEnergy(self.ManaCost)
  end
end

function SWEP:Deploy()
  self.seeking = false
  return true
end

function SWEP:OnRemove()
  if IsValid(self.currentEnergyBomb) then
    self.currentEnergyBomb:Remove()
  end
end

function SWEP:findTarget(filter,pos,range)
  local targets = ents.FindInSphere(pos,range)
  
  for k,ent in pairs (targets) do
    local height = 0
        
    if IsValid(ent) then
      if ent:IsPlayer() then
        if ent:Crouching() then
          height = 30
        else
          height = 50
        end
      end
    end
    local entpos = ent:GetPos()+Vector(0,0,height)
    local traceData = {}
    traceData.start = pos
    traceData.endpos = ent:GetPos()+Vector(0,0,height)
    traceData.filter = filter
    local tr = util.TraceLine( traceData )
    if tr.Entity:IsPlayer() and tr.Entity:Team() != self.Owner:Team() then
      return tr.Entity
    end
  end
end

function spawnLightning(pos,endPos,normal,arcs)
  local effectData = EffectData()
  effectData:SetOrigin(pos)
  effectData:SetNormal(normal)
  effectData:SetStart(endPos)
  effectData:SetScale(arcs)
  effectData:SetRadius(6)
  util.Effect("chainlightning",effectData)
end

function SWEP:Think()
	local myvector = self.Owner:GetAimVector()
	local myvector = Vector(myvector.x, myvector.y, myvector.z)
	local myvector = Vector(myvector.x, myvector.y, 0)

  if self.seeking then
    if self.lastSeek + 1 < CurTime() then
      self.Owner:EmitSound(seekingSound)
      self.lastSeek = CurTime()
    end
    
    local pos = self.Owner:GetShootPos()
    local tracedata = {}
    tracedata.start = pos
    tracedata.endpos = pos+(self.Owner:GetAimVector()*500)
    tracedata.filter = self.Owner

    local trace = util.TraceLine(tracedata)
    local hitEnt = trace.Entity
    if !IsValid(hitEnt) then return end
    if (hitEnt:IsPlayer() and hitEnt:Team() == self.Owner:Team()) or !hitEnt:IsPlayer() then return end
      
    timer.Simple(0.001,	function()	spawnLightning(self.Owner:GetShootPos(),hitEnt:GetPos(),self.Owner:GetAimVector(),50)		end)
    
    hitEnt:TakeDamage(70,self.Owner,self)
    hitEnt:SetVelocity( myvector * 2000) -- knockback lol
    self.Owner:EmitSound(chainLightningSound)
    local target = self:findTarget({self.Owner,hitEnt},hitEnt:GetPos(),600)
    
    if IsValid(target) then
      timer.Simple(0.05, function() spawnLightning(hitEnt:GetPos()+Vector(0,0,25), target:GetPos(), ( (target:GetPos()+Vector(0,0,25) )-hitEnt:GetPos()):Normalize(), 40)	end)
      
      target:TakeDamage(35,self.Owner,self)
      local oldTarget = target
      target = self:findTarget({self.Owner, hitEnt, target},target:GetPos(),600)
      if IsValid(target) then
        timer.Simple(0.05, function()	spawnLightning(oldTarget:GetPos()+Vector(0,0,25), target:GetPos()+Vector(0,0,25), ( (target:GetPos() + Vector(0,0,25) )-oldTarget:GetPos()):Normalize(), 40)	end	) 
        target:TakeDamage(18,self.Owner,self)
      end
    end
    self.seeking = false
  end
end

function SWEP:SecondaryAttack()
  if !self.Owner:HasSpecial(11) then self.Owner:ChatPrint("You do not have the special ability for this class. Press F1 and look in the Classes tab to buy it.") return end
  if self.seeking or self.Owner:Energy() < SORCERER_MANA_COST then return end
  self.seeking = true
  self.lastSeek = CurTime() - 2
  self.Owner:TakeEnergy(SORCERER_MANA_COST)
end