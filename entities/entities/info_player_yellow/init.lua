
ENT.Type = "point"

function ENT:Initialize()
	self:SetModel("models/player.mdl")
	self:SetColor(Color(255, 255, 0, 150))
	self:PhysicsInit(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
end

function ENT:KeyValue(key, value)
end

