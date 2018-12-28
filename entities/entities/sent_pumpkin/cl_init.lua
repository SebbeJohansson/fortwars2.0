ENT.Spawnable      = false
ENT.AdminSpawnable    = false

include( "shared.lua" )
local matBall2 = Material( "darkland/pumpkin2" )

if IS_CHRISTMAS then
  matBall2 = Material( "darkland/present2" ) 
else
  matBall2 = Material( "darkland/pumpkin2" )
end

function ENT:Draw()
  return false
end


hook.Add("PostDrawOpaqueRenderables", "FWHaloweener", function()
  for _, ent in pairs(ents.GetAll()) do
    if ent:GetClass()=="sent_pumpkin" then --ent:GetClass() == "ball" or 

      local pos = ent:GetPos()
      render.SetMaterial( matBall2 )
      render.DrawSprite( pos, 32, 32, Color( 255, 255, 255, 255 ) )
    end
  end
end)