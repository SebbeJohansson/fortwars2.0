AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
SpawnBoxes = {}
function ENT:Initialize()
  self:PhysicsInitBox( Vector( -16, -16, -1 ), Vector( 16, 16, 73 ) )
  self:SetCollisionBounds( Vector( -16, -16, -1 ), Vector( 16, 16, 73 ) )
  self:SetSolid( SOLID_BBOX )
  self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
  self:SetMoveType( MOVETYPE_NONE )
  self:DrawShadow( false )
  self.enabled = true
  self:SetTrigger(true)
  local phys = self:GetPhysicsObject()
  if IsValid(phys) then
    phys:EnableMotion(false)
    phys:Sleep()
  end

  local ent = ents.Create( "prop_dynamic" )
  ent:SetPos(self:GetPos())
  ent:SetAngles(self:GetAngles())
  ent:SetModel("models/roller.mdl")
  ent:SetNotSolid(true)
  ent:DrawShadow(false)
  ent:SetRenderMode( RENDERMODE_TRANSALPHA )
  ent:SetColor( Color(255, 255, 255, 200) )
  ent:Spawn()
  ent:Activate()
  self.effect = ent
end


function ENT:Enable()
  self:SetNotSolid(false)
  self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self.effect:SetNoDraw(false)
  self.enabled = true
end

function ENT:Disable()
  self:SetNotSolid(true)
  self:SetCollisionGroup(COLLISION_GROUP_NONE)
  self.effect:SetNoDraw(true)
  self.enabled = false
end

function ENT:OnTakeDamage(something) --spammed consolelooking for this
end

function ENT:PhysicsUpdate(something) --spammed consolelooking for this
end

function ENT:PhysicsCollide(something) --spammed consolelooking for this
end
function ENT:Use(something) --spammed consolelooking for this
end