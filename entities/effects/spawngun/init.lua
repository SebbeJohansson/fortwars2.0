
function EFFECT:Init( effectdata ) 
self.pos = effectdata:GetOrigin()+Vector(0,0,100)
self.Entity:SetPos(self.pos)
self.em = ParticleEmitter(self.pos)
self.Die = CurTime()+0.1
end
function EFFECT:Think()
	for i=1,3 do
		local x = math.random(-2,2)*10
		local y = math.random(-2,2)*10
		local part = self.em:Add("particles/smokey",self.pos+Vector(x,y,0))
		part:SetColor(math.random(150,255),20,20,255)
		part:SetVelocity(Vector(0,0,-1000))
		part:SetCollide(true)
		part:SetDieTime(0.7)
		part:SetStartAlpha(50)
		part:SetAirResistance(100)
		part:SetEndAlpha(0)
		part:SetLifeTime(0)
		part:SetStartSize(10)
	end
	return self.Die > CurTime()
end

function EFFECT:Render()
end