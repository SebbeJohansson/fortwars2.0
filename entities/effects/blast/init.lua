
function EFFECT:Init( effectdata ) 
self.pos = effectdata:GetOrigin()
self.Entity:SetPos(self.pos)
self.radius = effectdata:GetRadius()
self.TimeLeft = CurTime() + effectdata:GetMagnitude()*0.5 --if magnitude given is 1, effect will last for 0.5seconds
self.em = ParticleEmitter(self.pos)
end
function EFFECT:Think()
    for i=1, 2 do
	
	    local part = self.em:Add("particles/fire1",self.pos)
		    part:SetColor(math.random(255),20,20,math.random(255))
			part:SetVelocity(Vector(math.random(-9,9),math.random(-9,9),math.random(-3,3)):GetNormalized() * 300)
			part:SetGravity(Vector(0,0,-50))
			part:SetRoll(math.random(100))
			part:SetRollDelta(math.random(80))
		    part:SetDieTime(4)
		    part:SetLifeTime(0)
			part:SetStartSize(100)
		    part:SetEndSize(0)
	
	local Pos = Vector(math.random()*2 - 1,math.random()*2 - 1,math.random()*2 - 1):GetNormal() * self.radius
		Pos.x = Pos.x * 0.4
		Pos.y = Pos.y * 0.4
		local vel = Pos * 10
		
		
	local part = self.em:Add("particles/smokey",self.pos)
	part:SetColor(math.random()*50+1,math.random()*50+1,math.random()*50+1,150)
	part:SetVelocity(vel)
	part:SetGravity(Vector(0,0,0))
	part:SetRoll(math.random(1))
	part:SetRollDelta(math.random(1))
	part:SetDieTime(6)
	part:SetStartAlpha(50)
	part:SetAirResistance(100)
	part:SetEndAlpha(0)
	part:SetLifeTime(0)
	part:SetStartSize(50)
	part:SetEndSize(100)
	end
	return self.TimeLeft > CurTime()
end

function EFFECT:Render()
end