AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
  self:SetCollisionGroup( COLLISION_GROUP_NONE )
  self:SetMoveType( MOVETYPE_NONE )
  self:DrawShadow( false )
  self:SetTrigger( true )
  self:SetModel( "models/roller.mdl" )
  self:SetColor( 255,255,255,200 )
end

function ENT:SetEnabled( bool )
  self:SetNotSolid( not bool )
  self:SetNoDraw( not bool )
  if bool then
    self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
  else
    self:SetCollisionGroup( COLLISION_GROUP_NONE )
  end  
end

function ENT:OnTakeDamage() end
function ENT:PhysicsUpdate() end
function ENT:PhysicsCollide() end
function ENT:Use() end
