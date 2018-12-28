include( "shared.lua" )

ENT.Spawnable      = false
ENT.AdminSpawnable    = false

function ENT:Initialize()
  self:SetRenderBounds(Vector(-5,-5,-1), Vector(5,5,1))
end

function ENT:Draw()
  
  if !IsValid(self:GetOwner()) then return end
 // if LocalPlayer():Team() != self:GetOwner():Team() and !LocalPlayer():IsAdmin() then return end
  if whatmode == "Build" then
  if (LocalPlayer():Team() == self:GetOwner():Team()) or LocalPlayer():IsAdmin() then
    local ang = EyeAngles()
    cam.Start3D2D(self:GetPos()+Vector(0, 0, 50), Angle(0,ang.yaw,ang.roll) + Angle(0,-90,90), 0.5)
      draw.SimpleText(self:GetOwner():Nick().."'s spawn", "ClassNameSmall", 0,0, team.GetColor(self:GetOwner():Team()),1,1)
    cam.End3D2D()
  
  cam.Start3D2D(self:GetPos()+Vector(0, 0, 2),Angle(0, 0, 0), 0.25)  
    draw.RoundedBox(64, -64, -64, 128, 128, Color(255, 255, 255, 100))
    draw.RoundedBox(32, -32, -32, 64, 64, Color(255, 0, 0, 255))
    draw.RoundedBox(16, -16, -16, 32, 32, Color(255, 255, 255, 100))
  cam.End3D2D()
  
  cam.Start3D2D(self:GetPos()+Vector(0, 0, 1),Angle(180, 0, 0), 0.25)  -- Draw the same thing but underneath
    draw.RoundedBox(64, -64, -64, 128, 128, Color(255, 255, 255, 100))
    draw.RoundedBox(32, -32, -32, 64, 64, Color(255, 0, 0, 255))
    draw.RoundedBox(16, -16, -16, 32, 32, Color(255, 255, 255, 100))
  cam.End3D2D()
		end
	end
end