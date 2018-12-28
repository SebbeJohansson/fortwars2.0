AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
  self.Entity:SetModel( "models/roller.mdl" )
  self.Entity:SetColor(0, 0, 0, 1) -- Has to be at least 1 for ENT:Draw()
  self.Entity:SetMoveType(  MOVETYPE_NONE )   
  self.Entity:SetSolid( SOLID_NONE )  
end

